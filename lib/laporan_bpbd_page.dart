import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'bpbd_model.dart';

class LaporanBpbdPage extends StatefulWidget {
  final String role; // Role ini bisa Anda set 'bpbd'

  const LaporanBpbdPage({super.key, required this.role});

  @override
  State<LaporanBpbdPage> createState() => _LaporanBpbdPageState();
}

class _LaporanBpbdPageState extends State<LaporanBpbdPage> {
  final uraianController = TextEditingController();
  final jenisBencanaController = TextEditingController(); // Tambahan untuk BPBD
  final dampakKerusakanController = TextEditingController(); // Tambahan untuk BPBD
  final jumlahPengungsiController = TextEditingController(); // Tambahan untuk BPBD
  final bantuanDiberikanController = TextEditingController(); // Tambahan untuk BPBD

  File? foto;
  File? video;
  final picker = ImagePicker();

  String? _selectedDaerah; // Ganti dengan pilihan daerah yang relevan untuk BPBD

  final List<String> _daerahBpbdList = [
    'BPBD Kota Surabaya',
    'BPBD Sidoarjo',
    'BPBD Gresik',
  ];

  
  final Map<String, String> _instansiBpbdMapping = {
    'BPBD Kota Surabaya': 'Badan Penanggulangan Bencana Daerah Kota Surabaya',
    'BPBD Sidoarjo': 'Badan Penanggulangan Bencana Daerah Sidoarjo',
    'BPBD Gresik': 'Badan Penanggulangan Bencana Daerah Gresik',
  };

  VideoPlayerController? _videoController;
  bool _isVideocontrollerInitialized = false;

  // Mengubah primaryColor agar sesuai dengan HomeScreen (merah)
  final Color primaryColor = const Color(0xFFC71811);
  final Color secondaryDarkColor = const Color(0xFF9E0B08); // Tambahkan juga secondaryDarkColor jika diperlukan untuk konsistensi

  @override
  void dispose() {
    _videoController?.dispose();
    uraianController.dispose();
    jenisBencanaController.dispose();
    dampakKerusakanController.dispose();
    jumlahPengungsiController.dispose();
    bantuanDiberikanController.dispose();
    super.dispose();
  }

  Future<void> ambilFoto() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => foto = File(picked.path));
      // Pastikan showBerhasilDialog tidak memiliki .then() jika Anda ingin memanggilnya dari sini
      showBerhasilDialog(context, 'Gambar berhasil diunggah');
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

      showBerhasilDialog(context, 'Video berhasil direkam');
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
    if (_selectedDaerah == null || uraianController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi dan uraian wajib diisi")));
      return;
    }

    final now = DateTime.now();
    final String waktu = now.toIso8601String();
    final String jamMasuk = DateFormat('HH:mm:ss').format(now);

    // Pastikan Anda sudah membuat BpbdModel.dart
    final laporanBpbdBaru = BpbdModel(
      lokasi: _selectedDaerah!,
      uraian: uraianController.text,
      jenisBencana: jenisBencanaController.text.isNotEmpty ? jenisBencanaController.text : null,
      dampakKerusakan: dampakKerusakanController.text.isNotEmpty ? dampakKerusakanController.text : null,
      jumlahPengungsi: int.tryParse(jumlahPengungsiController.text) ?? 0,
      bantuanDiberikan: bantuanDiberikanController.text.isNotEmpty ? bantuanDiberikanController.text : null,
      waktu: waktu,
      jamMasuk: jamMasuk,
      status: 'Pending',
      fotoPath: foto?.path,
    );

    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.insertBpbd(laporanBpbdBaru.toMap()); // Gunakan toMap() dari BpbdModel

      // Menampilkan dialog berhasil dan kemudian menutup halaman laporan
      await showBerhasilDialog(context, 'Laporan BPBD berhasil terkirim'); // Menggunakan await karena showBerhasilDialog sekarang mengembalikan Future
      // Setelah dialog ditutup, kembali ke halaman sebelumnya (Home Screen)
      if (mounted) { // Pastikan widget masih ada di tree sebelum pop
        Navigator.pop(context);
      }

      setState(() {
        _selectedDaerah = null;
        uraianController.clear();
        jenisBencanaController.clear();
        dampakKerusakanController.clear();
        jumlahPengungsiController.clear();
        bantuanDiberikanController.clear();
        foto = null;
        video = null;
        _videoController?.dispose();
        _videoController = null;
        _isVideocontrollerInitialized = false;
      });
    } catch (e) {
      print("Error menyimpan laporan BPBD ke database: $e");
      if (mounted) { // Pastikan widget masih ada di tree sebelum menampilkan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim laporan BPBD: ${e.toString()}", style: GoogleFonts.poppins(color: Colors.white)),
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
          "Laporan BPBD",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor, // Menggunakan primaryColor dari HomeScreen
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
            Text("Lokasi Kejadian", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
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
                      });
                    },
                    items: _daerahBpbdList.map<DropdownMenuItem<String>>((String value) {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fungsi 'Ubah' untuk daerah belum diimplementasikan")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Menggunakan primaryColor
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                  child: const Text("Ubah", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text("Jenis Layanan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
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

            // --- Field Spesifik BPBD ---
            Text("Jenis Bencana", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
            const SizedBox(height: 8),
            TextFormField(
              controller: jenisBencanaController,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Misal: Banjir/Longsor/Gempa Bumi',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            Text("Dampak Kerusakan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
            const SizedBox(height: 8),
            TextFormField(
              controller: dampakKerusakanController,
              maxLines: 3,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Deskripsi dampak kerusakan',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            Text("Jumlah Pengungsi (Jika ada)", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
            const SizedBox(height: 8),
            TextFormField(
              controller: jumlahPengungsiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Jumlah pengungsi',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            Text("Bantuan yang Dibutuhkan/Diberikan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
            const SizedBox(height: 8),
            TextFormField(
              controller: bantuanDiberikanController,
              maxLines: 3,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Jenis bantuan (makanan, selimut, dll.)',
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder, // Menggunakan focusedBorder yang baru
                contentPadding: EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),
            // --- Akhir Field Spesifik BPBD ---

            const Divider(color: Colors.grey),
            const SizedBox(height: 10),

            Text("Dokumentasi", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
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

            Text("Uraian Laporan", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)), // Menggunakan primaryColor
            const SizedBox(height: 8),
            TextFormField(
              controller: uraianController,
              maxLines: 4,
              decoration: InputDecoration( // Ubah ke InputDecoration karena focusedBorder bukan const
                hintText: 'Isi detail laporan bencana',
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
