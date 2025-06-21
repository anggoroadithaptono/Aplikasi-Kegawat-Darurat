import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 

class LaporanDetailPage extends StatelessWidget {
  final Map<String, dynamic> laporanData;

  const LaporanDetailPage({super.key, required this.laporanData});

  final Color primaryColor = const Color(0xFFC71811); 

  // Fungsi untuk memformat tanggal dan waktu
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Tidak Diketahui';
    }
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd MMMMEEEE, HH:mm').format(dateTime);
    } catch (e) {
      // Jika format ISO8601 tidak valid, coba format sebagai waktu saja jika itu 'HH:mm:ss'
      try {
        final parts = dateTimeString.split(':');
        if (parts.length >= 2) { 
          return dateTimeString.substring(0, 5); 
        }
      } catch (_) {
      }
      return dateTimeString; 
    }
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

  @override
  Widget build(BuildContext context) {
    final String? fotoPath = laporanData['fotoPath'];
    final bool hasFoto = fotoPath != null && fotoPath.isNotEmpty && File(fotoPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detail Laporan",
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
            // Lokasi
            Text(
              "📍 Lokasi: ${laporanData['lokasi'] ?? 'Tidak Diketahui'}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Instansi
            Text(
              "🏢 Instansi: ${laporanData['instansi'] ?? 'Tidak Diketahui'}",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Jenis Laporan (Role)
            Text(
              "🏷️ Jenis Laporan: ${laporanData['role'] ?? 'Tidak Diketahui'}",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Waktu Laporan
            Text(
              "⏰ Waktu Laporan: ${_formatDateTime(laporanData['waktu'])}",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Jam Masuk (jika ada)
            if (laporanData['jamMasuk'] != null && laporanData['jamMasuk'].isNotEmpty)
              Text(
                "⏱️ Jam Masuk: ${_formatDateTime(laporanData['jamMasuk'])}",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
              ),
            const SizedBox(height: 10),

            // Uraian Laporan
            Text(
              "📝 Uraian Laporan:",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              laporanData['uraian'] ?? 'Tidak ada uraian.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5, color: Colors.grey[800]),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),

            // Foto Bukti
            if (hasFoto)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📷 Foto Bukti:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(fotoPath!),
                      height: 250, 
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.broken_image, size: 80, color: Colors.grey[500]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "Tidak ada foto terlampir",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Status Laporan
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(laporanData['status']),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  "Status: ${laporanData['status'] ?? 'Tidak Diketahui'}",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
