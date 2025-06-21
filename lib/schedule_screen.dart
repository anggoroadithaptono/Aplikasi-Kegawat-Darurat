import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart'; 
import 'news_schedule_screen.dart'; 

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My News",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC71811),
        leading: IconButton( 
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: const NewsContent(),
    );
  }
}

class NewsContent extends StatefulWidget {
  const NewsContent({super.key});

  @override
  State<NewsContent> createState() => _NewsContentState();
}

class _NewsContentState extends State<NewsContent> {
  final Color primaryColor = const Color(0xFFC71811); 

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
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
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final beritaList = snapshot.data ?? [];

          if (beritaList.isEmpty) {
            return const Center(child: Text('Tidak ada berita.'));
          }

          return ListView.builder(
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              return _buildBeritaCardFromDB(beritaList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildBeritaCardFromDB(Map<String, dynamic> berita) {
    final String imagePath = berita['media_path'] ?? '';
    final bool isAsset = imagePath.startsWith('assets/');
    final bool hasImage = imagePath.isNotEmpty && (isAsset || File(imagePath).existsSync());

    final String title = berita['judul'] ?? '';
    final String description = berita['deskripsi'] ?? '';
    final String instansi = berita['instansi'] ?? '';
    final String tanggal = (berita['tanggal'] as String?)?.split('T').first ?? '';

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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: isAsset
                    ? Image.asset(
                        imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
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
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
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
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(color: Colors.grey),
                    maxLines: 3, 
                    overflow: TextOverflow.ellipsis, 
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        instansi,
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        tanggal,
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
