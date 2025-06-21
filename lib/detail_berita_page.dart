// File: detail_berita_page.dart (Contoh, pastikan ini sudah Anda miliki)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailBeritaPage extends StatelessWidget {
  final Map<String, dynamic> berita;

  const DetailBeritaPage({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final String? imagePath = berita['media_path'];
    // Periksa apakah path adalah asset atau file lokal
    final bool isAsset = imagePath != null && imagePath.startsWith('assets/');
    final bool hasValidFile = imagePath != null && File(imagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          berita['judul'] ?? 'Detail Berita',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar dari asset atau file lokal
            if (isAsset && imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity, height: 200),
              )
            else if (hasValidFile)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity, height: 200),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              berita['judul'] ?? 'Tidak ada Judul',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Instansi: ${berita['instansi'] ?? 'Tidak Diketahui'}',
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            Text(
              'Lokasi: ${berita['lokasi'] ?? 'Tidak Diketahui'}', // Menampilkan lokasi
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            Text(
              'Tanggal: ${berita['tanggal'] != null ? DateFormat('dd MMMM yyyy').format(DateTime.parse(berita['tanggal'])) : 'Tidak Diketahui'}',
              style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              berita['deskripsi'] ?? 'Tidak ada Deskripsi.',
              style: GoogleFonts.poppins(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}