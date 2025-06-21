import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'detail_sos.dart'; 

class EmergencyLocation {
  final LatLng coordinates;
  final IconData icon;
  final String name;
  final String address;
  final String phoneNumber;
  final double rating;
  final int reviews;
  final String category; 
  final String distanceTime;
  final List<String> tags;
  final List<String> photos;
  final List<Review> reviewsList;
  final String? openUntil;
  final String? specialNote;

  EmergencyLocation({
    required this.coordinates,
    required this.icon,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.rating = 4.6,
    this.reviews = 99,
    required this.category, 
    this.distanceTime = "10 mnt",
    this.tags = const [],
    this.photos = const [],
    this.reviewsList = const [],
    this.openUntil,
    this.specialNote,
  });
}

class Review {
  final String author;
  final String avatarUrl;
  final String comment;
  final double? rating;

  Review({
    required this.author,
    required this.comment,
    this.avatarUrl = "",
    this.rating,
  });
}

// ---
// SOSScreen: Mengelola state filter dan meneruskannya ke OpenStreetMapView
// ---
class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  // State untuk menyimpan filter yang sedang aktif
  String? _activeFilterCategory; // 'Polisi', 'Medis', 'Pemadam', 'BPBD', atau null (untuk semua)

  void _onFilterSelected(String? category) {
    setState(() {
      if (_activeFilterCategory == category) {
        // Jika filter yang sama diklik lagi, reset filter (tampilkan semua)
        _activeFilterCategory = null;
      } else {
        _activeFilterCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Meneruskan filter category ke OpenStreetMapView
          OpenStreetMapView(activeFilterCategory: _activeFilterCategory),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: SOSButtonMenu(
                onFilterSelected: _onFilterSelected,
                activeFilterCategory: _activeFilterCategory, // Teruskan juga filter aktif
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---
// SOSButtonMenu: Memanggil callback saat tombol instansi diklik
// ---
class SOSButtonMenu extends StatefulWidget {
  final Function(String?) onFilterSelected;
  final String? activeFilterCategory;

  const SOSButtonMenu({
    super.key,
    required this.onFilterSelected,
    this.activeFilterCategory,
  });

  @override
  State<SOSButtonMenu> createState() => _SOSButtonMenuState();
}

class _SOSButtonMenuState extends State<SOSButtonMenu> {
  bool _isMenuVisible = false;

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (_isMenuVisible)
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEmergencyButton(context, Icons.local_police, "Polisi", "tel:110", "Polisi"),
                  _buildEmergencyButton(context, Icons.local_hospital, "Medis", "tel:112", "Medis"),
                  _buildEmergencyButton(context, Icons.fire_truck, "Pemadam", "tel:113", "Pemadam"),
                  _buildEmergencyButton(context, Icons.warning, "BPBD", "tel:115", "BPBD"),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            onPressed: _toggleMenu,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Colors.red,
            ),
            child: const Icon(Icons.sos, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyButton(
      BuildContext context, IconData icon, String label, String phoneNumber, String filterCategory) {
    // Tentukan apakah tombol ini sedang aktif/terfilter
    final bool isActive = widget.activeFilterCategory == filterCategory;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            // Panggil callback untuk memfilter map
            widget.onFilterSelected(filterCategory);
            // Anda bisa tambahkan logika untuk menelepon juga jika perlu, tapi fokusnya di filter
            // _callEmergency(context, phoneNumber);
          },
          // Ubah warna ikon jika aktif
          icon: Icon(icon, color: isActive ? Colors.blue : Colors.red),
          iconSize: 36,
        ),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Future<void> _callEmergency(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka telepon")),
        );
      }
    }
  }
}

// ---
// OpenStreetMapView: Memfilter marker berdasarkan category
// ---
class OpenStreetMapView extends StatefulWidget {
  final String? activeFilterCategory; // Terima filter category dari parent

  const OpenStreetMapView({super.key, this.activeFilterCategory});

  @override
  State<OpenStreetMapView> createState() => _OpenStreetMapViewState();
}

class _OpenStreetMapViewState extends State<OpenStreetMapView> {
  // === DATA LOKASI INSTANSI YANG DIPERBANYAK ===
  final List<EmergencyLocation> allEmergencyLocations = [
    // --- KEPOLISIAN ---
    EmergencyLocation(
      coordinates: LatLng(-7.265757, 112.734146), // Polsek Gayungan
      icon: Icons.local_police,
      name: "Polsek Gayungan",
      address: "Jl. Sikatan No.1, Ketintang, Kec. Gayungan, Surabaya",
      phoneNumber: "0318280053", // Contoh nomor lokal
      category: "Polisi", // Kategori sesuai tombol
      openUntil: "Buka 24 jam",
      tags: ["polisi", "keamanan"],
      photos: ["assets/polsekgayungan.jpg"], // Pastikan assets ini ada
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.291771, 112.721469), // Polsek Jambangan
      icon: Icons.local_police,
      name: "Polsek Jambangan",
      address: "Jl. Raya Jambangan No.100, Jambangan, Kec. Jambangan, Surabaya",
      phoneNumber: "0318280110",
      category: "Polisi",
      openUntil: "Buka 24 jam",
      tags: ["polisi", "keamanan"],
      photos: ["assets/police2.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.279612, 112.766348), // Polsek Gubeng
      icon: Icons.local_police,
      name: "Polsek Gubeng",
      address: "Jl. Raya Gubeng No.45, Gubeng, Kec. Gubeng, Surabaya",
      phoneNumber: "0315024477",
      category: "Polisi",
      openUntil: "Buka 24 jam",
      tags: ["polisi", "keamanan"],
      photos: ["assets/police3.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.298064, 112.737152), // Polsek Wonocolo
      icon: Icons.local_police,
      name: "Polsek Wonocolo",
      address: "Jl. Raya Jemursari No.10, Wonocolo, Kec. Wonocolo, Surabaya",
      phoneNumber: "0318430073",
      category: "Polisi",
      openUntil: "Buka 24 jam",
      tags: ["polisi", "keamanan"],
      photos: ["assets/police1.jpg"],
    ),

    // --- MEDIS (Rumah Sakit / Puskesmas) ---
    EmergencyLocation(
      coordinates: LatLng(-7.282375, 112.792130), // RSUD Dr. Soetomo
      icon: Icons.local_hospital,
      name: "RSUD Dr. Soetomo",
      address: "Jl. Prof. dr. Moestopo No.6-8, Airlangga, Kec. Gubeng, Surabaya",
      phoneNumber: "0315501078",
      category: "Medis", // Kategori sesuai tombol
      openUntil: "Buka 24 jam",
      tags: ["UGD", "rumah sakit", "ambulans"],
      photos: ["assets/hospital1.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.258525, 112.720173), // RS Mitra Keluarga Surabaya
      icon: Icons.local_hospital,
      name: "RS Mitra Keluarga",
      address: "Jl. Satelit Indah II No.5, Darmo Satelit, Surabaya",
      phoneNumber: "0317345333",
      category: "Medis",
      openUntil: "Buka 24 jam",
      tags: ["UGD", "rumah sakit"],
      photos: ["assets/hospital2.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.304523, 112.715362), // Puskesmas Jambangan
      icon: Icons.medical_services,
      name: "Puskesmas Jambangan",
      address: "Jl. Ketintang Baru III, Jambangan, Kec. Jambangan, Surabaya",
      phoneNumber: "0318280010",
      category: "Medis",
      openUntil: "Buka sampai 16:00",
      tags: ["puskesmas", "kesehatan dasar"],
      photos: ["assets/medical1.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.260844, 112.735166), // Puskesmas Gayungan
      icon: Icons.medical_services,
      name: "Puskesmas Gayungan",
      address: "Jl. Gayungsari Barat I No.4, Gayungan, Kec. Gayungan, Surabaya",
      phoneNumber: "0318280011",
      category: "Medis",
      openUntil: "Buka sampai 16:00",
      tags: ["puskesmas", "kesehatan dasar"],
      photos: ["assets/medical2.jpg"],
    ),

    // --- PEMADAM KEBAKARAN ---
    EmergencyLocation(
      coordinates: LatLng(-7.258457, 112.750645), // PMK Pasar Turi (Markas Utama)
      icon: Icons.fire_truck,
      name: "PMK Pasar Turi",
      address: "Jl. Pasar Turi No.1, Bubutan, Kec. Bubutan, Surabaya",
      phoneNumber: "0313550000",
      category: "Pemadam", // Kategori sesuai tombol
      openUntil: "Buka 24 jam",
      tags: ["kebakaran", "rescue", "pemadam"],
      photos: ["assets/fire1.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.300588, 112.748386), // Pos PMK Rungkut
      icon: Icons.fire_truck,
      name: "Pos PMK Rungkut",
      address: "Jl. Raya Rungkut Industri I, Rungkut Kidul, Surabaya",
      phoneNumber: "0318430000",
      category: "Pemadam",
      openUntil: "Buka 24 jam",
      tags: ["kebakaran", "rescue"],
      photos: ["assets/fire2.jpg"],
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.255959, 112.697424), // Pos PMK Darmo
      icon: Icons.fire_truck,
      name: "Pos PMK Darmo",
      address: "Jl. Raya Darmo, Darmo, Kec. Wonokromo, Surabaya",
      phoneNumber: "0315610000",
      category: "Pemadam",
      openUntil: "Buka 24 jam",
      tags: ["kebakaran", "rescue"],
      photos: ["assets/fire3.jpg"],
    ),

    // --- BPBD ---
    EmergencyLocation(
      coordinates: LatLng(-7.265147, 112.766861), // BPBD Kota Surabaya (Kantor Pusat)
      icon: Icons.shield, // Menggunakan ikon yang lebih umum untuk BPBD
      name: "BPBD Kota Surabaya",
      address: "Jl. Manyar Kertoarjo No.1, Manyar Sabrangan, Surabaya",
      phoneNumber: "0315999000",
      category: "BPBD", // Kategori sesuai tombol
      openUntil: "Buka 24 jam",
      tags: ["bencana", "evakuasi", "mitigasi"],
      photos: ["assets/bpbd1.jpg"], // Pastikan assets ini ada
    ),
    EmergencyLocation(
      coordinates: LatLng(-7.310243, 112.775083), // Pos BPBD Gunung Anyar
      icon: Icons.shield,
      name: "Pos BPBD Gunung Anyar",
      address: "Jl. Raya Gunung Anyar Sawah No.1, Gunung Anyar, Surabaya",
      phoneNumber: "0318700000",
      category: "BPBD",
      openUntil: "Buka 24 jam",
      tags: ["bencana", "banjir"],
      photos: ["assets/bpbd2.jpg"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter lokasi berdasarkan activeFilterCategory yang diterima dari widget
    final List<EmergencyLocation> filteredLocations =
        widget.activeFilterCategory == null
            ? allEmergencyLocations // Jika null, tampilkan semua
            : allEmergencyLocations
                .where((loc) => loc.category == widget.activeFilterCategory)
                .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(-7.250445, 112.768845), // Pusat peta di Surabaya
        initialZoom: 12.0, // Zoom out sedikit untuk melihat lebih banyak lokasi
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(
          markers: List.generate(filteredLocations.length, (index) {
            final location = filteredLocations[index];
            return Marker(
              width: 90.0, // Perbesar sedikit agar teks terlihat
              height: 90.0,
              point: location.coordinates,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return GoogleMapsStyleBottomSheet(location: location);
                    },
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5), // Sedikit lebih besar
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3), // Shadow lebih gelap
                            spreadRadius: 1,
                            blurRadius: 4, // Blur lebih besar
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(location.icon, color: Colors.red, size: 35), // Ukuran ikon sedikit lebih besar
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Padding lebih besar
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Lebih tidak transparan
                        borderRadius: BorderRadius.circular(6), // Lebih rounded
                      ),
                      child: Text(
                        location.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87), // Teks lebih jelas
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}