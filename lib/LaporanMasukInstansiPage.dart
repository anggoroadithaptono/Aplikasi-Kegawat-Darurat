import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import 'database_helper.dart';
import 'laporan_model.dart';
import 'pemadam_model.dart';
import 'medis_model.dart';
import 'bpbd_model.dart';
import 'laporan_detail_page.dart';


class LaporanMasukInstansiPage extends StatefulWidget {
  const LaporanMasukInstansiPage({super.key});

  @override
  State<LaporanMasukInstansiPage> createState() =>
      _LaporanMasukInstansiPageState();
}

class _LaporanMasukInstansiPageState extends State<LaporanMasukInstansiPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Daftar semua laporan yang diambil dari database.
  List<Map<String, dynamic>> _laporanList = [];
  // Status loading untuk mengelola tampilan saat data sedang dimuat.
  bool _isLoading = true;
  // Warna utama aplikasi (misalnya merah kepolisian).
  final Color primaryColor = const Color(0xFFC71811);

  // Controller untuk TabBar agar bisa beralih antara "Laporan Masuk" dan "Laporan Selesai".
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Menambahkan observer untuk memantau siklus hidup aplikasi (resume, pause, dll.).
    WidgetsBinding.instance.addObserver(this);
    // Menginisialisasi TabController dengan 2 tab.
    _tabController = TabController(length: 2, vsync: this);
    // Menambahkan listener untuk menangani perubahan tab.
    _tabController.addListener(_handleTabSelection);
    // Memuat data laporan saat halaman pertama kali diinisialisasi.
    _fetchLaporanData();
  }

  @override
  void dispose() {
    // Melepas observer dan listener untuk menghindari memory leak.
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  /// Dipanggil ketika siklus hidup aplikasi berubah (misalnya, aplikasi kembali dari background).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed. Re-fetching all reports data...");
      // Muat ulang data laporan saat aplikasi kembali aktif.
      _fetchLaporanData();
    } else if (state == AppLifecycleState.paused) {
      print("App paused.");
    }
  }

  /// Menangani perubahan pada seleksi tab.
  void _handleTabSelection() {
    // Memeriksa jika perpindahan tab sedang terjadi (bukan hanya memilih tab yang sama).
    if (!_tabController.indexIsChanging) {
      // Panggil setState untuk memicu build ulang dan memperbarui tampilan berdasarkan tab yang dipilih.
      // Data sudah difilter di dalam metode build.
      setState(() {
        // Data sudah di-fetch dan di-filter di build method
      });
    }
  }

  /// Mengambil semua data laporan dari berbagai tabel database
  /// (laporan umum, pemadam, medis, bpbd) dan menggabungkannya.
  Future<void> _fetchLaporanData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    try {
      final dbHelper = DatabaseHelper();

      // Ambil data dari masing-masing tabel laporan
      final List<Map<String, dynamic>> laporanUmum =
          await dbHelper.getAllLaporan();
      final List<Map<String, dynamic>> laporanPemadam =
          await dbHelper.getAllPemadam();
      final List<Map<String, dynamic>> laporanMedis =
          await dbHelper.getAllMedis();
      final List<Map<String, dynamic>> laporanBpbd =
          await dbHelper.getAllBpbd();

      // Gabungkan semua laporan menjadi satu daftar tunggal.
      List<Map<String, dynamic>> allReports = [];

      // Tambahkan data dari tabel 'laporan' (kepolisian/umum)
      for (var report in laporanUmum) {
        allReports.add({
          ...report,
          'instansi_type':
              'Kepolisian', // Menambahkan identifier tipe instansi
          'display_instansi': report['instansi'] ??
              'Kepolisian (Umum)', // Teks yang akan ditampilkan
        });
      }

      // Tambahkan data dari tabel 'pemadam'
      for (var report in laporanPemadam) {
        allReports.add({
          ...report,
          'instansi_type':
              'Pemadam', // Menambahkan identifier tipe instansi
          'display_instansi':
              'Pemadam Kebakaran', // Teks yang akan ditampilkan
        });
      }

      // Tambahkan data dari tabel 'medis'
      for (var report in laporanMedis) {
        allReports.add({
          ...report,
          'instansi_type': 'Medis', // Menambahkan identifier tipe instansi
          'display_instansi':
              'Layanan Medis Darurat', // Teks yang akan ditampilkan
        });
      }

      // Tambahkan data dari tabel 'bpbd'
      for (var report in laporanBpbd) {
        allReports.add({
          ...report,
          'instansi_type': 'BPBD', // Menambahkan identifier tipe instansi
          'display_instansi':
              'Badan Penanggulangan Bencana Daerah', // Teks yang akan ditampilkan
        });
      }

      // Urutkan semua laporan berdasarkan waktu (terbaru di atas).
      allReports.sort((a, b) {
        final DateTime timeA = DateTime.parse(a['waktu'] as String);
        final DateTime timeB = DateTime.parse(b['waktu'] as String);
        return timeB.compareTo(timeA);
      });

      // Perbarui state dengan daftar laporan yang sudah digabungkan dan diurutkan.
      setState(() {
        _laporanList = allReports;
        _isLoading = false; // Set loading state to false
      });
      print("Total reports fetched: ${_laporanList.length}");
    } catch (e) {
      // Tangani error saat mengambil data.
      print("Error fetching all reports data: $e");
      setState(() {
        _isLoading = false; // Set loading state to false bahkan jika ada error
      });
      // Tampilkan snackbar dengan pesan error.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal memuat semua data laporan: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Memformat string tanggal/waktu menjadi format yang lebih mudah dibaca.
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Tidak Diketahui';
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMMM HH:mm').format(dateTime);
    } catch (e) {
      // Fallback jika parsing DateTime gagal (misalnya, hanya string jam:menit).
      try {
        final parts = dateTimeString.split(':');
        if (parts.length >= 2) {
          return dateTimeString.substring(0, 5); // Ambil hanya HH:mm
        }
      } catch (_) {
        // Abaikan error jika fallback juga gagal
      }
      return dateTimeString; // Kembali ke string asli jika semua gagal
    }
  }

  /// Fungsi untuk menghapus laporan dari database berdasarkan ID dan tipe instansi.
  Future<void> _deleteLaporan(int id, String instansiType) async {
    // Tampilkan dialog konfirmasi sebelum menghapus laporan.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            "Apakah Anda yakin ingin menghapus laporan ini dari $instansiType?",
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Batal menghapus
            child: Text("Batal",
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.pop(context, true), // Konfirmasi hapus
            child: Text("Hapus",
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    // Lanjutkan jika pengguna mengkonfirmasi penghapusan.
    if (confirm == true) {
      try {
        final dbHelper = DatabaseHelper();
        int rowsAffected = 0;

        // Panggil metode penghapusan yang sesuai berdasarkan tipe instansi.
        switch (instansiType) {
          case 'Kepolisian':
            rowsAffected = await dbHelper.deleteLaporan(id);
            break;
          case 'Pemadam':
            rowsAffected = await dbHelper.deletePemadam(id);
            break;
          case 'Medis':
            rowsAffected = await dbHelper.deleteMedis(id);
            break;
          case 'BPBD':
            rowsAffected = await dbHelper.deleteBpbd(id);
            break;
          default:
            print("Unknown instansi type: $instansiType for deletion.");
            break;
        }

        // Tampilkan snackbar berdasarkan hasil penghapusan.
        if (rowsAffected > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Laporan berhasil dihapus dari $instansiType",
                    style: GoogleFonts.poppins())),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Gagal menghapus laporan atau laporan tidak ditemukan.",
                    style: GoogleFonts.poppins(color: Colors.white))),
          );
        }
        _fetchLaporanData(); // Muat ulang data setelah menghapus
      } catch (e) {
        // Tangani error saat proses penghapusan.
        print("Error deleting laporan from $instansiType: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal menghapus laporan: $e",
                  style: GoogleFonts.poppins())),
        );
      }
    }
  }

  /// Fungsi untuk memperbarui status laporan di database.
  /// Memerlukan ID laporan, status baru, tipe instansi, dan data laporan saat ini.
  Future<void> _updateLaporanStatus(
      int id, String newStatus, String instansiType, Map<String, dynamic> currentLaporan) async {
    print("Attempting to update status for ID: $id, new status: $newStatus for $instansiType");

    try {
      final dbHelper = DatabaseHelper();
      int rowsAffected = 0;

      // Buat salinan data laporan saat ini dan perbarui statusnya.
      // Ini penting karena `currentLaporan` berisi semua data spesifik tabel.
      final Map<String, dynamic> dataToUpdate = Map<String, dynamic>.from(currentLaporan);
      dataToUpdate['status'] = newStatus;

      // Panggil metode pembaruan yang sesuai berdasarkan tipe instansi,
      // mengonversi Map ke Model jika diperlukan (contoh untuk `LaporanModel`).
      switch (instansiType) {
        case 'Kepolisian':
          final updatedLaporanModel = LaporanModel.fromMap(dataToUpdate);
          rowsAffected = await dbHelper.updateLaporan(id, updatedLaporanModel.toMap());
          break;
        case 'Pemadam':
          final updatedPemadamModel = PemadamModel.fromMap(dataToUpdate);
          rowsAffected = await dbHelper.updatePemadam(id, updatedPemadamModel.toMap());
          break;
        case 'Medis':
          final updatedMedisModel = MedisModel.fromMap(dataToUpdate);
          rowsAffected = await dbHelper.updateMedis(id, updatedMedisModel.toMap());
          break;
        case 'BPBD':
          final updatedBpbdModel = BpbdModel.fromMap(dataToUpdate);
          rowsAffected = await dbHelper.updateBpbd(id, updatedBpbdModel.toMap());
          break;
        default:
          print("Unknown instansi type: $instansiType for update.");
          break;
      }

      // Tampilkan snackbar berdasarkan hasil pembaruan.
      if (rowsAffected > 0) {
        print("Database update successful for ID: $id ($instansiType)");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Status laporan $instansiType diperbarui menjadi: $newStatus",
                  style: GoogleFonts.poppins())),
        );
        // Muat ulang data untuk merefleksikan perubahan di UI.
        await _fetchLaporanData();
        // Jika status baru mengandung 'selesai', pindah ke tab "Laporan Selesai".
        if (newStatus.toLowerCase().contains('selesai')) {
          _tabController.animateTo(1);
        }
      } else {
        print("Laporan with ID $id ($instansiType) not found or no changes made.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Laporan tidak ditemukan atau tidak ada perubahan.",
                  style: GoogleFonts.poppins(color: Colors.white))),
        );
      }
    } catch (e) {
      // Tangani error saat proses pembaruan status.
      print("❌ Error updating laporan status for $instansiType: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal memperbarui status laporan: $e",
                style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter laporan berdasarkan tab yang aktif.
    List<Map<String, dynamic>> filteredLaporan = [];
    if (_tabController.index == 0) {
      // Tab "Laporan Masuk": Menampilkan laporan dengan status pending, menunggu, atau proses.
      filteredLaporan = _laporanList.where((laporan) {
        final status = laporan['status']?.toLowerCase() ?? '';
        return status.contains('pending') ||
            status.contains('menunggu') ||
            status.contains('proses');
      }).toList();
    } else {
      // Tab "Laporan Selesai": Menampilkan laporan dengan status selesai, ditolak, atau palsu.
      filteredLaporan = _laporanList.where((laporan) {
        final status = laporan['status']?.toLowerCase() ?? '';
        return status.contains('selesai') ||
            status.contains('ditolak') ||
            status.contains('palsu');
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Masuk Instansi", // Judul AppBar
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor, // Warna latar belakang AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), // Tombol kembali
        ),
        centerTitle: true, // Pusatkan judul
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: "Laporan Masuk"), // Teks untuk tab pertama
            Tab(text: "Laporan Selesai"), // Teks untuk tab kedua
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              // Tampilkan indikator loading jika data masih dimuat.
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Menampilkan daftar laporan yang difilter untuk masing-masing tab.
                _buildLaporanListView(filteredLaporan),
                _buildLaporanListView(filteredLaporan),
              ],
            ),
    );
  }

  /// Membangun ListView untuk menampilkan daftar laporan.
  Widget _buildLaporanListView(List<Map<String, dynamic>> laporanList) {
    if (laporanList.isEmpty) {
      // Tampilkan pesan jika tidak ada laporan di kategori ini.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              "Belum ada laporan di kategori ini.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Bangun ListView berisi Card untuk setiap laporan.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: laporanList.length,
      itemBuilder: (context, index) {
        final laporan = laporanList[index];
        final String? fotoPath = laporan['fotoPath'];
        // Memeriksa apakah ada foto dan file foto tersebut benar-benar ada.
        final bool hasFoto =
            fotoPath != null && fotoPath.isNotEmpty && File(fotoPath).existsSync();

        // Memeriksa apakah status laporan sudah selesai.
        final bool isStatusSelesai =
            laporan['status']?.toLowerCase().contains('selesai') ?? false;

        // Dapatkan tipe instansi yang ditambahkan saat fetch data.
        final String instansiType = laporan['instansi_type'] ?? 'Unknown';
        // Dapatkan nama instansi yang akan ditampilkan.
        final String displayInstansiName = laporan['display_instansi'] ?? 'Instansi Tidak Diketahui';

        // Tentukan icon dan warna berdasarkan tipe instansi untuk tampilan visual.
        IconData instansiIcon;
        Color instansiColor;
        switch (instansiType) {
          case 'Kepolisian':
            instansiIcon = Icons.local_police;
            instansiColor = primaryColor; // Merah
            break;
          case 'Pemadam':
            instansiIcon = Icons.fire_truck;
            instansiColor = Colors.orange;
            break;
          case 'Medis':
            instansiIcon = Icons.medical_services;
            instansiColor = Colors.blue;
            break;
          case 'BPBD':
            instansiIcon = Icons.shield;
            instansiColor = Colors.green;
            break;
          default:
            instansiIcon = Icons.business;
            instansiColor = Colors.grey;
            break;
        }

        return Card(
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // Navigasi ke halaman detail laporan saat card diketuk.
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Kirim semua data laporan ke halaman detail
                  builder: (context) => LaporanDetailPage(laporanData: laporan),
                ),
              ).then((_) {
                // Muat ulang data setelah kembali dari halaman detail (jika ada perubahan status).
                _fetchLaporanData();
              });
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
                          // Menampilkan lokasi laporan.
                          "📍 ${laporan['lokasi'] ?? 'Tidak Diketahui'}",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Tombol hapus laporan.
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (laporan['id'] != null) {
                            // Panggil fungsi hapus dengan ID dan tipe instansi.
                            _deleteLaporan(laporan['id'], instansiType);
                          } else {
                            print("Error: Laporan ID is null, cannot delete.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Tidak dapat menghapus: ID laporan tidak valid.",
                                      style: GoogleFonts.poppins(color: Colors.white))),
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
                      // Avatar dengan icon dan warna instansi.
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: instansiColor.withOpacity(0.1),
                        child: Icon(instansiIcon, color: instansiColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama instansi yang dinamis.
                            Text(
                              displayInstansiName,
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Waktu laporan masuk.
                            Text(
                              "Laporan masuk: ${_formatDateTime(laporan['jamMasuk'] ?? laporan['waktu'])}",
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      // Tombol panggil instansi.
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () async {
                          // Mengambil nomor telepon dari laporan.
                          // Asumsi: Laporan memiliki kunci 'nomorPelapor' atau 'nomorKontak' untuk nomor telepon.
                          String? phoneNumber = laporan['nomorPelapor'] ?? laporan['nomorKontak'];

                          // Jika nomor telepon tidak tersedia, gunakan nomor dummy.
                          if (phoneNumber == null || phoneNumber.isEmpty) {
                            phoneNumber = "081234567890"; // Nomor telepon dummy
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(" $phoneNumber")),
                            );
                          }

                          // Coba panggil nomor telepon.
                          final Uri uri = Uri.parse("tel:$phoneNumber");
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Tidak dapat melakukan panggilan telepon ke $phoneNumber.")),
                            );
                          }
                        },
                        tooltip: 'Hubungi Pelapor', // Diubah tooltipnya karena ini adalah panggilan ke pelapor
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tampilan detail spesifik berdasarkan kolom yang ada di laporan (tipe instansi).
                  // Ini akan tampil jika kolom ada di map `laporan`, terlepas dari asalnya.
                  if (laporan['jenis_kebakaran'] != null)
                    Text(
                      "Jenis Kebakaran: ${laporan['jenis_kebakaran'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['korban_jiwa'] != null)
                    Text(
                      "Korban Jiwa: ${laporan['korban_jiwa'] ?? '0'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['kerugian_estimasi'] != null)
                    Text(
                      "Estimasi Kerugian: ${laporan['kerugian_estimasi'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  // Medis
                  if (laporan['jenis_darurat'] != null)
                    Text(
                      "Jenis Darurat: ${laporan['jenis_darurat'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['jumlah_korban'] != null)
                    Text(
                      "Jumlah Korban: ${laporan['jumlah_korban'] ?? '0'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['kondisi_pasien'] != null)
                    Text(
                      "Kondisi Pasien: ${laporan['kondisi_pasien'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['penanganan_awal'] != null)
                    Text(
                      "Penanganan Awal: ${laporan['penanganan_awal'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  // BPBD
                  if (laporan['jenis_bencana'] != null)
                    Text(
                      "Jenis Bencana: ${laporan['jenis_bencana'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['dampak_kerusakan'] != null)
                    Text(
                      "Dampak Kerusakan: ${laporan['dampak_kerusakan'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['jumlah_pengungsi'] != null)
                    Text(
                      "Jumlah Pengungsi: ${laporan['jumlah_pengungsi'] ?? '0'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  if (laporan['bantuan_diberikan'] != null)
                    Text(
                      "Bantuan Diberikan: ${laporan['bantuan_diberikan'] ?? '-'}",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  const SizedBox(height: 8),

                  // Uraian Laporan (tetap ada untuk semua tipe laporan)
                  Text(
                    laporan['uraian'] ?? 'Tidak ada uraian.',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                    textAlign: TextAlign.justify,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Menampilkan foto bukti jika ada dan file-nya valid.
                  if (hasFoto)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📷 Foto Bukti:",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(fotoPath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // Penanganan error jika gambar tidak bisa dimuat.
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.broken_image,
                                      size: 60, color: Colors.grey[500]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Tombol "Tandai sebagai Selesai" hanya tampil jika laporan belum selesai.
                  if (!isStatusSelesai)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (laporan['id'] != null) {
                            // Panggil fungsi update status.
                            _updateLaporanStatus(
                                laporan['id'] as int, 'Selesai', instansiType, laporan);
                          } else {
                            print("Error: Laporan ID is null, cannot update status.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Tidak dapat memperbarui status: ID laporan tidak valid.",
                                      style: GoogleFonts.poppins(color: Colors.white))),
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
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Menampilkan status laporan saat ini.
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Status saat ini: ${laporan['status'] ?? 'Tidak Diketahui'}",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _getStatusColor(laporan['status']), // Warna status dinamis
                          fontWeight: FontWeight.bold),
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

  /// Mengembalikan warna teks berdasarkan status laporan.
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('selesai')) {
      return Colors.green;
    } else if (lowerStatus.contains('proses') ||
        lowerStatus.contains('pending') ||
        lowerStatus.contains('menunggu')) {
      return Colors.orange;
    } else if (lowerStatus.contains('ditolak') ||
        lowerStatus.contains('palsu')) {
      return Colors.red;
    }
    return Colors.blue; // Default color
  }
}
