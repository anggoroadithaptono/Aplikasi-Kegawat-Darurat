import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'pemadam_model.dart'; 
import 'laporan_detail_page.dart';

class LaporanMasukPemadamPage extends StatefulWidget {
  const LaporanMasukPemadamPage({super.key});

  @override
  State<LaporanMasukPemadamPage> createState() => _LaporanMasukPemadamPageState();
}

class _LaporanMasukPemadamPageState extends State<LaporanMasukPemadamPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Map<String, dynamic>> _laporanList = [];
  bool _isLoading = true;
  final Color primaryColor = Colors.orange; // Warna khas Pemadam
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchLaporanPemadamData(); // Panggil fungsi fetch khusus Pemadam
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed. Re-fetching Pemadam data...");
      _fetchLaporanPemadamData();
    } else if (state == AppLifecycleState.paused) {
      print("App paused. Closing database connection for Pemadam...");
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        // State akan diperbarui saat _laporanList di-filter di build method
      });
    }
  }

  // Fungsi untuk mengambil data laporan Pemadam
  Future<void> _fetchLaporanPemadamData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dbHelper = DatabaseHelper();
      final data = await dbHelper.getAllPemadam(); // Ganti dengan getAllPemadam()
      setState(() {
        _laporanList = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching Pemadam data: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal memuat data laporan Pemadam: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Tidak Diketahui';
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMMM HH:mm').format(dateTime);
    } catch (e) {
      try {
        final parts = dateTimeString.split(':');
        if (parts.length >= 2) {
          return dateTimeString.substring(0, 5);
        }
      } catch (_) {}
      return dateTimeString;
    }
  }

  Future<void> _deleteLaporan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus laporan ini?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper().deletePemadam(id); // Ganti dengan deletePemadam()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Laporan Pemadam berhasil dihapus", style: GoogleFonts.poppins())),
        );
        _fetchLaporanPemadamData(); // Muat ulang data setelah menghapus
      } catch (e) {
        print("Error deleting Pemadam laporan: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus laporan Pemadam: $e", style: GoogleFonts.poppins())),
        );
      }
    }
  }

  Future<void> _updateLaporanStatus(int id, String newStatus) async {
    print("Attempting to update status for Pemadam ID: $id, new status: $newStatus");

    try {
      final dbHelper = DatabaseHelper();
      final index = _laporanList.indexWhere((l) => l['id'] == id);
      if (index != -1) {
        final laporanToUpdate = Map<String, dynamic>.from(_laporanList[index]);
        laporanToUpdate['status'] = newStatus;
        // Pastikan Anda menggunakan PemadamModel untuk toMap() jika Anda sudah membuatnya
        // Kalau tidak, langsung update map-nya
        await dbHelper.updatePemadam(id, laporanToUpdate); // Ganti dengan updatePemadam()
        print("Database update successful for Pemadam ID: $id");

        setState(() {
          _laporanList[index] = laporanToUpdate;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status laporan Pemadam diperbarui menjadi: $newStatus", style: GoogleFonts.poppins())),
        );

        await _fetchLaporanPemadamData(); // Muat ulang data untuk merefleksikan perubahan

        if (newStatus.toLowerCase().contains('selesai')) {
          _tabController.animateTo(1);
        }
      } else {
        print("Laporan Pemadam with ID $id not found in local list.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Laporan Pemadam tidak ditemukan untuk diperbarui.", style: GoogleFonts.poppins(color: Colors.white))),
        );
      }
    } catch (e) {
      print("❌ Error updating Pemadam status: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui status laporan Pemadam: $e", style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredLaporan = [];
    if (_tabController.index == 0) {
      filteredLaporan = _laporanList.where((laporan) {
        final status = laporan['status']?.toLowerCase() ?? '';
        return status.contains('pending') || status.contains('menunggu') || status.contains('proses');
      }).toList();
    } else {
      filteredLaporan = _laporanList.where((laporan) {
        final status = laporan['status']?.toLowerCase() ?? '';
        return status.contains('selesai') || status.contains('ditolak') || status.contains('palsu');
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Pemadam Kebakaran", // Judul AppBar khusus Pemadam
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: "Laporan Masuk"),
            Tab(text: "Laporan Selesai"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLaporanListView(filteredLaporan),
                _buildLaporanListView(filteredLaporan),
              ],
            ),
    );
  }

  Widget _buildLaporanListView(List<Map<String, dynamic>> laporanList) {
    if (laporanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              "Belum ada laporan Pemadam di kategori ini.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: laporanList.length,
      itemBuilder: (context, index) {
        final laporan = laporanList[index];
        final String? fotoPath = laporan['fotoPath'];
        final bool hasFoto = fotoPath != null && fotoPath.isNotEmpty && File(fotoPath).existsSync();

        final bool isStatusSelesai = laporan['status']?.toLowerCase().contains('selesai') ?? false;

        return Card(
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LaporanDetailPage(laporanData: laporan), // Bisa gunakan LaporanDetailPage yang sama
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "📍 ${laporan['lokasi'] ?? 'Tidak Diketahui'}",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (laporan['id'] != null) {
                            _deleteLaporan(laporan['id']);
                          } else {
                            print("Error: Laporan ID is null, cannot delete.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Tidak dapat menghapus: ID laporan tidak valid.", style: GoogleFonts.poppins(color: Colors.white))),
                            );
                          }
                        },
                        tooltip: 'Hapus Laporan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Icon(Icons.fire_truck, color: primaryColor, size: 20), // Icon Pemadam
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pemadam Kebakaran", // Tampilkan nama instansi secara spesifik
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Laporan masuk: ${_formatDateTime(laporan['jamMasuk'] ?? laporan['waktu'])}",
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Fungsi telepon untuk Pemadam belum diimplementasikan")),
                          );
                        },
                        tooltip: 'Hubungi Instansi',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Detail spesifik Pemadam
                  Text(
                    "Jenis Kebakaran: ${laporan['jenis_kebakaran'] ?? '-'}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87),
                  ),
                  Text(
                    "Korban Jiwa: ${laporan['korban_jiwa'] ?? '0'}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87),
                  ),
                  Text(
                    "Estimasi Kerugian: ${laporan['kerugian_estimasi'] ?? '-'}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    laporan['uraian'] ?? 'Tidak ada uraian.',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                    textAlign: TextAlign.justify,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  if (hasFoto)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📷 Foto Bukti:",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(fotoPath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey[500]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  if (!isStatusSelesai)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (laporan['id'] != null) {
                            _updateLaporanStatus(laporan['id'] as int, 'Selesai');
                          } else {
                            print("Error: Laporan ID is null, cannot update status.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Tidak dapat memperbarui status: ID laporan tidak valid.", style: GoogleFonts.poppins(color: Colors.white))),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Tandai sebagai Selesai",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Status saat ini: ${laporan['status'] ?? 'Tidak Diketahui'}",
                      style: GoogleFonts.poppins(fontSize: 12, color: _getStatusColor(laporan['status']), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('selesai')) {
      return Colors.green;
    } else if (lowerStatus.contains('proses') || lowerStatus.contains('pending') || lowerStatus.contains('menunggu')) {
      return Colors.orange;
    } else if (lowerStatus.contains('ditolak') || lowerStatus.contains('palsu')) {
      return Colors.red;
    }
    return Colors.blue;
  }
}