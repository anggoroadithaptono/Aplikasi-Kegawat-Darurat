import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> newsData;

  const NewsDetailScreen({super.key, required this.newsData});

  @override
  Widget build(BuildContext context) {
    final String imagePath = newsData['media_path'] ?? '';
    final bool isAsset = imagePath.startsWith('assets/');
    final bool hasImage = imagePath.isNotEmpty && (isAsset || File(imagePath).existsSync());

    final String title = newsData['judul'] ?? 'Tidak ada Judul';
    final String description = newsData['deskripsi'] ?? 'Tidak ada Deskripsi';
    final String instansi = newsData['instansi'] ?? 'Tidak Diketahui';
    final String tanggal = (newsData['tanggal'] as String?)?.split('T').first ?? 'Tanggal Tidak Diketahui';

    final Color primaryColor = const Color(0xFFC71811);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Berita",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Berita
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isAsset
                    ? Image.asset(
                        imagePath,
                        height: 250, // Tinggi gambar yang lebih besar
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
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
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
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
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),
            const SizedBox(height: 16),

            // Judul Berita
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // Instansi dan Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  instansi,
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  tanggal,
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.grey), // Divider untuk pemisah

            // Deskripsi Lengkap
            Text(
              description, // Menampilkan deskripsi lengkap di sini
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify, // Teks rata kiri-kanan
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}