import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:ui'; // Import ini dibutuhkan untuk ImageFilter.blur
import 'dart:io'; // Import ini dibutuhkan untuk File (untuk Image.file)

import 'laporan_pemadam_page.dart';
import 'laporan_medis_page.dart';
import 'laporan_bpbd_page.dart';

import 'departments_page.dart'; 
import 'news_page.dart'; 
import 'schedule_screen.dart';
import 'sos_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'laporan_non_darurat_page.dart'; 
import 'news_schedule_screen.dart'; 
import 'database_helper.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFFC71811);
  final Color accentColor = const Color(0xFFFFEFD7);
  final Color secondaryDarkColor = const Color(0xFF9E0B08);

  final List<Widget> _pages = [
    HomeScreenContent(),
    ScheduleScreen(), 
    SOSScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: primaryColor,
        buttonBackgroundColor: primaryColor,
        height: 60,
        animationDuration: const Duration(milliseconds: 400),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.article, size: 30, color: Colors.white), 
          Icon(Icons.sos, size: 30, color: Colors.white),
          Icon(Icons.groups, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final Color primaryColor = const Color(0xFFC71811);
  final Color accentColor = const Color(0xFFFFEFD7);
  final Color secondaryDarkColor = const Color(0xFF9E0B08);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildMainMenu(context),
          const SizedBox(height: 20),
          const NewsFromDatabaseSection(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage("assets/pam.jpg"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Halo, Sigap 24/7!",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: AssetImage("assets/weather_background.jpg"), // Pastikan gambar ini ada
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rabu, 23 Desember", // Ini bisa diubah dinamis nanti
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                "Rungkut Madya", // Ini bisa diubah dinamis nanti
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "21°", // Ini bisa diubah dinamis nanti
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hujan Petir", // Ini bisa diubah dinamis nanti
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "H:29° L:15°", // Ini bisa diubah dinamis nanti
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Layanan Non-SOS",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 15, // Spacing yang sedikit lebih besar
            crossAxisSpacing: 15, 
            childAspectRatio: 0.9, // Sesuaikan rasio aspek agar elemen lebih proporsional
            children: [
              _buildMenuItem(
                // Atau pastikan 'assets/polisi.jpg' adalah gambar lingkaran dengan ikon polisi di dalamnya
                imagePath: "assets/polisi.jpg",
                iconData: Icons.local_police, 
                title: "Polisi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanNonDaruratPage(role: 'polisi'),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                imagePath: "assets/pemadam.png",
                iconData: Icons.fire_extinguisher, 
                title: "Pemadam",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanPemadamPage(role: 'pemadam'),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                imagePath: "assets/medis.png",
                iconData: Icons.medical_services,
                title: "Medis",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanMedisPage(role: 'medis'),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                imagePath: "assets/bpbd.jpg",
                iconData: Icons.assistant_photo, 
                title: "BPBD",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporanBpbdPage(role: 'bpbd'),
                    ),
                  );
                },
              ),
              // Tambahkan menu "Lainnya" seperti di gambar Anda
              _buildMenuItem(
                imagePath: null, // Tidak ada gambar asset spesifik
                iconData: Icons.apps, // Menggunakan ikon "apps" seperti di gambar Anda
                title: "Lainnya",
                onTap: () {
                  _showOthersMenu(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mengubah _buildMenuItem agar lebih fleksibel bisa menerima imagePath atau iconData
  Widget _buildMenuItem({
    String? imagePath, // Nullable untuk menandakan bisa tidak ada gambar
    IconData? iconData, // Tambahkan parameter untuk ikon Flutter
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logika untuk menampilkan gambar atau ikon
            if (imagePath != null && imagePath.startsWith('assets/'))
              ClipRRect(
                borderRadius: BorderRadius.circular(50), // Membuat lingkaran
                child: Image.asset(
                  imagePath,
                  width: 60, // Ukuran ikon diperbesar sedikit
                  height: 60, // Ukuran ikon diperbesar sedikit
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika gambar asset tidak ditemukan
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: secondaryDarkColor, // Warna latar belakang ikon
                        shape: BoxShape.circle, // Bentuk lingkaran
                      ),
                      child: Center(
                        child: Icon(iconData ?? Icons.error_outline, size: 40, color: Colors.white),
                      ),
                    );
                  },
                ),
              )
            else if (iconData != null) // Jika imagePath null tapi iconData ada
              Container(
                width: 60, // Ukuran ikon diperbesar sedikit
                height: 60, // Ukuran ikon diperbesar sedikit
                decoration: BoxDecoration(
                  color: secondaryDarkColor, // Warna latar belakang ikon
                  shape: BoxShape.circle, // Bentuk lingkaran
                ),
                child: Center(
                  child: Icon(iconData, size: 40, color: Colors.white),
                ),
              )
            else // Fallback jika tidak ada gambar dan tidak ada ikon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: secondaryDarkColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.white),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOthersMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            children: [
              _buildOtherOption(Icons.lightbulb_outline, "PLN", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'pln'),
                  ),
                );
              }),
              _buildOtherOption(Icons.cloud_outlined, "BMKG", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'bmkg_other'),
                  ),
                  );
              }),
              _buildOtherOption(Icons.water_drop_outlined, "PDAM", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'pdam'),
                  ),
                );
              }),
              _buildOtherOption(Icons.local_gas_station, "PERTAMINA", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'pertamina'),
                  ),
                );
              }),
              _buildOtherOption(Icons.wifi, "ISP", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'isp'),
                  ),
                );
              }),
              _buildOtherOption(Icons.eco_outlined, "BLH", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanNonDaruratPage(role: 'blh'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtherOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: primaryColor),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsFromDatabaseSection extends StatefulWidget {
  const NewsFromDatabaseSection({super.key});

  @override
  State<NewsFromDatabaseSection> createState() => _NewsFromDatabaseSectionState();
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsData;

  const NewsDetailScreen({super.key, required this.newsData});

  @override
  Widget build(BuildContext context) {
    final String imagePath = newsData['media_path'] ?? '';
    final bool isAsset = imagePath.startsWith('assets/');
    final bool hasImage = imagePath.isNotEmpty && (isAsset || File(imagePath).existsSync());

    return Scaffold(
      appBar: AppBar(
        title: Text(newsData['judul'] ?? 'Detail Berita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              isAsset
                  ? Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: 200)
                  : Image.file(File(imagePath), fit: BoxFit.cover, width: double.infinity, height: 200),
            const SizedBox(height: 16),
            Text(
              newsData['judul'] ?? 'Tidak ada Judul',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Instansi: ${newsData['instansi'] ?? 'Tidak Diketahui'}',
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            Text(
              'Tanggal: ${newsData['tanggal']?.split('T').first ?? 'Tidak Diketahui'}',
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              newsData['deskripsi'] ?? 'Tidak ada Deskripsi',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


class _NewsFromDatabaseSectionState extends State<NewsFromDatabaseSection> {
  final Color primaryColor = const Color(0xFFC71811);

  Widget _buildNewsCardFromDB(Map<String, dynamic> berita) {
    final String imagePath = berita['media_path'] ?? '';

    final bool isAsset = imagePath.startsWith('assets/');
    final bool hasImage = imagePath.isNotEmpty && (isAsset || File(imagePath).existsSync());

    final String title = berita['judul'] ?? 'Tidak ada Judul';
    final String description = berita['deskripsi'] ?? 'Tidak ada Deskripsi';
    final String instansi = berita['instansi'] ?? 'Tidak Diketahui';
    final String tanggal = (berita['tanggal'] as String?)?.split('T').first ?? 'Tanggal Tidak Diketahui';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsData: berita),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: isAsset
                    ? Image.asset(
                        imagePath,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Asset not found',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                'Image file not found',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          );
                        },
                      ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        instansi,
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 10),
                      ),
                      Text(
                        tanggal,
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Buletin Hari Ini",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                  );
                },
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper().getAllNewsInstansi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC71811)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat berita: ${snapshot.error}\nPastikan DatabaseHelper berfungsi dan tabel ada.'));
                }

                final beritaList = snapshot.data ?? [];

                if (beritaList.isEmpty) {
                  return const Center(child: Text('Tidak ada berita terbaru saat ini.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: beritaList.length,
                  itemBuilder: (context, index) {
                    return _buildNewsCardFromDB(beritaList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}