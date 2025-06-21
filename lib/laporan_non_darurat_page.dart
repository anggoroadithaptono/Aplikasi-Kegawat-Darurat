import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu

import 'database_helper.dart';
import 'laporan_model.dart';

class LaporanNonDaruratPage extends StatefulWidget {
  final String role;

  const LaporanNonDaruratPage({super.key, required this.role});

  @override
  State<LaporanNonDaruratPage> createState() => _LaporanNonDaruratPageState();
}

class _LaporanNonDaruratPageState extends State<LaporanNonDaruratPage> {
  final instansiController = TextEditingController();
  final uraianController = TextEditingController();

  File? foto;
  File? video;
  final picker = ImagePicker();

  String? _selectedDaerah;

  final List<String> _daerahList = [
    'Rungkut',
    'Mer',
    'Karangpilang',
  ];

  final Map<String, String> _instansiMapping = {
    'Rungkut': 'Dinas Kepolisian Surabaya timur',
    'Mer': 'Dinas Kepolisian Surabaya Pusat',
    'Karangpilang': 'Dinas Kepolisian Surabaya Barat',
  };

  VideoPlayerController? _videoController;
  bool _isVideocontrollerInitialized = false;

  final Color primaryColor = const Color(0xFFC71811); // Merah utama
  final Color secondaryDarkColor = const Color(0xFF9E0B08); // Tambahkan juga secondaryDarkColor jika diperlukan untuk konsistensi

  @override
  void dispose() {
    _videoController?.dispose();
    instansiController.dispose();
    uraianController.dispose();
    super.dispose();
  }

  Future<void> ambilFoto() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => foto = File(picked.path));
      // Menggunakan await karena showBerhasilDialog sekarang mengembalikan Future
      await showBerhasilDialog(context, 'Gambar berhasil diunggah');
    }
  }

  Future<void> rekamVideo() async {
    final picked = await picker.pickVideo(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        video = File(picked.path);
        _isVideocontrollerInitialized = false;

        _videoController?.dispose();
        _videoController = null;
      });

      _videoController = VideoPlayerController.file(video!)
        ..initialize().then((_) {
          setState(() {
            _isVideocontrollerInitialized = true;
          });
        }).catchError((error) {
          print('Error initializing video controller: $error');
          _isVideocontrollerInitialized = false;
        });

      // Menggunakan await karena showBerhasilDialog sekarang mengembalikan Future
      await showBerhasilDialog(context, 'Video berhasil direkam');
    }
  }

  // Mengubah showBerhasilDialog agar mengembalikan Future<void>
  Future<void> showBerhasilDialog(BuildContext context, String message) async {
    return showDialog<void>( // Mengembalikan Future<void>
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green), // Biarkan hijau untuk sukses
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text('Terima kasih', style: GoogleFonts.poppins(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Menggunakan primaryColor dari HomeScreen
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Menutup dialog "Berhasil"
                },
                child: Text('Lanjut', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void simpanLaporan() async {
    if (_selectedDaerah == null || instansiController.text.isEmpty || uraianController.text.isEmpty) {
      if (mounted) { // Tambahkan pengecekan mounted
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      }
      return;
    }

    // Ambil waktu saat ini untuk 'waktu' dan 'jamMasuk'
    final now = DateTime.now();
    final String waktu = now.toIso8601String();
    final String jamMasuk = DateFormat('HH:mm:ss').format(now);

    // Buat objek LaporanModel (dari laporan_model.dart)
    final laporanBaru = LaporanModel(
      lokasi: _selectedDaerah!,
      instansi: instansiController.text,
      uraian: uraianController.text,
      role: widget.role,
      waktu: waktu,
      jamMasuk: jamMasuk,
      status: 'Pending',
      fotoPath: foto?.path,
    );

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.insertLaporan(laporanBaru);

      // Menampilkan dialog berhasil dan kemudian menutup halaman laporan
      await showBerhasilDialog(context, 'Laporan berhasil terkirim'); // Menggunakan await karena showBerhasilDialog sekarang mengembalikan Future
      // Setelah dialog ditutup, kembali ke halaman sebelumnya (Home Screen)
      if (mounted) { // Pastikan widget masih ada di tree sebelum pop
        Navigator.pop(context);
      }

      // Kosongkan form dan reset video player
      setState(() {
        _selectedDaerah = null;
        instansiController.clear();
        uraianController.clear();
        foto = null;
        video = null;
        _videoController?.dispose();
        _videoController = null;
        _isVideocontrollerInitialized = false;
      });
    } catch (e) {
      print("Error menyimpan laporan ke database: $e");
      if (mounted) { // Pastikan widget masih ada di tree sebelum menampilkan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim laporan: ${e.toString()}", style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.5),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
    final focusedBorder = OutlineInputBorder( // Diubah menjadi final karena menggunakan primaryColor
      borderSide: BorderSide(color: primaryColor, width: 1.0), // Warna border sesuai primaryColor
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Laporan Non-Darurat",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lokasi", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDaerah,
                    decoration: InputDecoration(
                      hintText: 'Pilih Daerah',
                      prefixIcon: Icon(Icons.location_on, color: primaryColor, size: 20), // Menggunakan primaryColor
                      border: border,
                      enabledBorder: border,
                      focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: primaryColor), // Menggunakan primaryColor
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDaerah = newValue;
                        if (newValue != null && _instansiMapping.containsKey(newValue)) {
                          instansiController.text = _instansiMapping[newValue]!;
                        } else {
                          instansiController.clear();
                        }
                      });
                    },
                    items: _daerahList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) { // Tambahkan pengecekan mounted
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fungsi 'Ubah' untuk daerah belum diimplementasikan")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                  child: const Text("Ubah", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text("Jenis Layanan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              initialValue: widget.role.toUpperCase(),
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            Text("Instansi Terdekat", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: instansiController,
              readOnly: true,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Pilih Instansi',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            const Divider(color: Colors.grey),
            const SizedBox(height: 10),

            Text("Dokumentasi", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: ambilFoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: primaryColor, size: 28), // Menggunakan primaryColor
                          const SizedBox(height: 5),
                          Text('Ambil Gambar', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: rekamVideo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, color: primaryColor, size: 28), // Menggunakan primaryColor
                          const SizedBox(height: 5),
                          Text('Rekam Video', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (foto != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      foto!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (video != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _isVideocontrollerInitialized && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController!),
                            VideoProgressIndicator(_videoController!, allowScrubbing: true, colors: VideoProgressColors(playedColor: primaryColor)), // Menggunakan primaryColor
                            Align(
                              alignment: Alignment.center,
                              child: FloatingActionButton(
                                mini: true,
                                backgroundColor: Colors.white.withOpacity(0.7),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.value.isPlaying
                                        ? _videoController!.pause()
                                        : _videoController!.play();
                                  });
                                },
                                child: Icon(
                                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: primaryColor, // Menggunakan primaryColor
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        height: 150,
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: primaryColor), // Menggunakan primaryColor
                      ),
              ),
            const SizedBox(height: 20),

            Text("Uraian Laporan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextFormField(
              controller: uraianController,
              maxLines: 4,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Isi detail laporan',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: simpanLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, // Menggunakan primaryColor
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                child: const Text("Kirim Laporan", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
