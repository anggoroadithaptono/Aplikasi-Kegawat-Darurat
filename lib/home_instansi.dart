import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:ui';
import 'dart:io';

import 'berita_instansi.dart'; 
import 'LaporanMasukInstansiPage.dart';
import 'mapsinstansi_detail_page.dart';
import 'profileinstansi_screen.dart';
import 'news_schedule_screen.dart';
import 'database_helper.dart';
import 'pemadam_model.dart';
import 'medis_model.dart';
import 'bpbd_model.dart';
import 'rekap_instansi_detail_page.dart';


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

class HomeInstansi extends StatefulWidget {
  const HomeInstansi({super.key});

  @override
  State<HomeInstansi> createState() => _HomeInstansiState();
}

class _HomeInstansiState extends State<HomeInstansi> {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFFC71811); // Merah utama

  final List<Widget> _pages = [
    const HomeInstansiContent(),
    const BeritaInstansiPage(),
    const InstansiMapPage(),
    const LaporanMasukInstansiPage(),
    const ProfilPenggunaPage(),
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
          Icon(Icons.map, size: 30, color: Colors.white),
          Icon(Icons.receipt_long, size: 30, color: Colors.white),
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

class HomeInstansiContent extends StatefulWidget {
  const HomeInstansiContent({super.key});

  @override
  State<HomeInstansiContent> createState() => _HomeInstansiContentState();
}

class _HomeInstansiContentState extends State<HomeInstansiContent> {
  final Color primaryColor = const Color(0xFFC71811);
  final Color accentColor = const Color(0xFFFFEFD7);

  // Ganti variabel total laporan berdasarkan status menjadi total berdasarkan instansi
  int _totalKepolisian = 0;
  int _totalPemadam = 0;
  int _totalMedis = 0;
  int _totalBpbd = 0;
  int _totalReports = 0; // Total keseluruhan laporan
  bool _isLoadingLaporan = true;

  List<Map<String, dynamic>> _newsInstansiList = [];
  bool _isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _fetchLaporanData();
    _fetchNewsInstansi();
  }

  // MODIFIKASI LENGKAP: Mengambil dan menghitung data berdasarkan instansi
  Future<void> _fetchLaporanData() async {
    setState(() {
      _isLoadingLaporan = true;
    });
    try {
      final dbHelper = DatabaseHelper();

      // Ambil data dari masing-masing tabel
      final List<Map<String, dynamic>> laporanUmum = await dbHelper.getAllLaporan();
      final List<Map<String, dynamic>> laporanPemadam = await dbHelper.getAllPemadam();
      final List<Map<String, dynamic>> laporanMedis = await dbHelper.getAllMedis();
      final List<Map<String, dynamic>> laporanBpbd = await dbHelper.getAllBpbd();

      // Reset counters
      int kepolisianCount = 0;
      int pemadamCount = 0;
      int medisCount = 0;
      int bpbdCount = 0;
      int totalReportsCount = 0;

      // Hitung laporan dari masing-masing tabel
      kepolisianCount = laporanUmum.length;
      pemadamCount = laporanPemadam.length;
      medisCount = laporanMedis.length;
      bpbdCount = laporanBpbd.length;

      totalReportsCount = kepolisianCount + pemadamCount + medisCount + bpbdCount;

      setState(() {
        _totalKepolisian = kepolisianCount;
        _totalPemadam = pemadamCount;
        _totalMedis = medisCount;
        _totalBpbd = bpbdCount;
        _totalReports = totalReportsCount;
        _isLoadingLaporan = false;
      });

      print("Total laporan Kepolisian: $_totalKepolisian");
      print("Total laporan Pemadam: $_totalPemadam");
      print("Total laporan Medis: $_totalMedis");
      print("Total laporan BPBD: $_totalBpbd");
      print("Total keseluruhan laporan: $_totalReports");

    } catch (e) {
      print("Error fetching all laporan data for recap by instansi: $e");
      setState(() {
        _isLoadingLaporan = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat rekapitulasi laporan: ${e.toString().split(':')[0]}')),
      );
    }
  }


  Future<void> _fetchNewsInstansi() async {
    setState(() {
      _isLoadingNews = true;
    });
    try {
      final dbHelper = DatabaseHelper();
      final List<Map<String, dynamic>> newsList = await dbHelper.getAllNewsInstansi();

      newsList.sort((a, b) {
        final dateA = DateTime.parse(a['tanggal'] ?? '2000-01-01');
        final dateB = DateTime.parse(b['tanggal'] ?? '2000-01-01');
        return dateB.compareTo(dateA);
      });

      _newsInstansiList = newsList.take(4).toList();

      setState(() {
        _isLoadingNews = false;
      });
    } catch (e) {
      print("Error fetching news instansi data: $e");
      setState(() {
        _isLoadingNews = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat buletin: ${e.toString().split(':')[0]}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchLaporanData();
        await _fetchNewsInstansi();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context),
            _buildWeatherCard(),
            const SizedBox(height: 20),
            _buildLaporanRecapSection(context), // Ini yang akan diubah
            const SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/pmi_logo.png"),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Halo, PMI Surabaya",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Stack(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage("assets/weather_background.jpg"),
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
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rabu, 28 Desember", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                        Text("Rungkut Madya", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Hujan Petir", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    Text("21°", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("H:29° L:15°", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MODIFIKASI LENGKAP: Pie chart berdasarkan instansi
  Widget _buildLaporanRecapSection(BuildContext context) {
    // Hitung persentase untuk setiap instansi
    double kepolisianPercentage = _totalReports > 0 ? (_totalKepolisian / _totalReports) : 0.0;
    double pemadamPercentage = _totalReports > 0 ? (_totalPemadam / _totalReports) : 0.0;
    double medisPercentage = _totalReports > 0 ? (_totalMedis / _totalReports) : 0.0;
    double bpbdPercentage = _totalReports > 0 ? (_totalBpbd / _totalReports) : 0.0;

    // Definisikan warna untuk setiap instansi
    final Color kepolisianColor = primaryColor; // Merah
    final Color pemadamColor = Colors.orange;
    final Color medisColor = Colors.blue;
    final Color bpbdColor = Colors.green;

    List<PieChartSectionData> sections = [];
    if (_totalReports == 0) {
      // Jika tidak ada laporan sama sekali, tampilkan satu slice kosong
      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100, // 100% dari 0 laporan
          title: '0%',
          radius: 80,
          titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      );
    } else {
      if (_totalKepolisian > 0) {
        sections.add(
          PieChartSectionData(
            color: kepolisianColor,
            value: kepolisianPercentage * 100, // Menggunakan persentase sebagai value
            title: '${(kepolisianPercentage * 100).toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
      if (_totalPemadam > 0) {
        sections.add(
          PieChartSectionData(
            color: pemadamColor,
            value: pemadamPercentage * 100,
            title: '${(pemadamPercentage * 100).toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
      if (_totalMedis > 0) {
        sections.add(
          PieChartSectionData(
            color: medisColor,
            value: medisPercentage * 100,
            title: '${(medisPercentage * 100).toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
      if (_totalBpbd > 0) {
        sections.add(
          PieChartSectionData(
            color: bpbdColor,
            value: bpbdPercentage * 100,
            title: '${(bpbdPercentage * 100).toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rekapitulasi Laporan",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  // Navigasi ke halaman detail rekapitulasi instansi
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RekapInstansiDetailPage(
                      totalKepolisian: _totalKepolisian,
                      totalPemadam: _totalPemadam,
                      totalMedis: _totalMedis,
                      totalBpbd: _totalBpbd,
                      totalReports: _totalReports,
                    )),
                  );
                },
                child: Text(
                  "Lihat detail",
                  style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoadingLaporan
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC71811)),
                  ),
                )
              : Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: sections, // Menggunakan sections yang sudah dihitung
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        // centerSlice: false, // Jika ingin menghilangkan lingkaran tengah, tapi tetap ada text Rekapitulasi Laporan Non SOS
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          // Legenda berdasarkan instansi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(kepolisianColor, "Kepolisian: $_totalKepolisian"),
              _buildLegendItem(pemadamColor, "Pemadam Kebakaran: $_totalPemadam"),
              _buildLegendItem(medisColor, "Bantuan Medis: $_totalMedis"),
              _buildLegendItem(bpbdColor, "BPBD: $_totalBpbd"),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Total Semua Laporan: $_totalReports",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

    
  

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news) {
    final String? imagePath = news['media_path'];
    final bool hasValidImage = imagePath != null && (imagePath.startsWith('assets/') || File(imagePath).existsSync());

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreen(newsData: news)),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasValidImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: imagePath!.startsWith('assets/')
                    ? Image.asset(
                        imagePath,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image from path $imagePath: $error");
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading image from path $imagePath: $error");
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          );
                        },
                      ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['judul'] ?? 'Judul Berita',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news['deskripsi'] ?? 'Deskripsi singkat berita.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}