// File: rekap_instansi_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class RekapInstansiDetailPage extends StatelessWidget {
  final int totalKepolisian;
  final int totalPemadam;
  final int totalMedis;
  final int totalBpbd;
  final int totalReports;

  const RekapInstansiDetailPage({
    super.key,
    required this.totalKepolisian,
    required this.totalPemadam,
    required this.totalMedis,
    required this.totalBpbd,
    required this.totalReports,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFC71811); // Merah utama
    final Color kepolisianColor = primaryColor;
    final Color pemadamColor = Colors.orange;
    final Color medisColor = Colors.blue;
    final Color bpbdColor = Colors.green;

    // Hitung persentase untuk setiap instansi
    double kepolisianPercentage = totalReports > 0 ? (totalKepolisian / totalReports) : 0.0;
    double pemadamPercentage = totalReports > 0 ? (totalPemadam / totalReports) : 0.0;
    double medisPercentage = totalReports > 0 ? (totalMedis / totalReports) : 0.0;
    double bpbdPercentage = totalReports > 0 ? (totalBpbd / totalReports) : 0.0;

    List<PieChartSectionData> sections = [];
    if (totalReports == 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 80,
          titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      );
    } else {
      if (totalKepolisian > 0) {
        sections.add(
          PieChartSectionData(
            color: kepolisianColor,
            value: kepolisianPercentage * 100,
            title: '${(kepolisianPercentage * 100).toStringAsFixed(0)}%',
            radius: 80,
            titleStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      }
      if (totalPemadam > 0) {
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
      if (totalMedis > 0) {
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
      if (totalBpbd > 0) {
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


    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rekapitulasi Laporan",
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
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Rekapitulasi Laporan Berdasarkan Instansi",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailCard(kepolisianColor, "Kepolisian", totalKepolisian, kepolisianPercentage),
            _buildDetailCard(pemadamColor, "Pemadam Kebakaran", totalPemadam, pemadamPercentage),
            _buildDetailCard(medisColor, "Bantuan Medis", totalMedis, medisPercentage),
            _buildDetailCard(bpbdColor, "BPBD", totalBpbd, bpbdPercentage),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Total Semua Laporan: $totalReports",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Color color, String title, int count, double percentage) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Jumlah: $count",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}