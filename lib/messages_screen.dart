import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'database_helper.dart'; 
import 'news_form_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _news = [];
  final Color primaryColor = const Color(0xFFC71811);

  void _fetchNews() async {

    final data = await DatabaseHelper().getNews();
    setState(() {
      _news = data;
    });
  }

  void _navigateToForm({Map<String, dynamic>? existingNews}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsFormScreen(existingNews: existingNews)),
    );
    if (result == true) _fetchNews(); 
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Konfirmasi Hapus",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus berita ini?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Hapus",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteNews(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Berita berhasil dihapus",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _fetchNews(); 
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Berita Komunitas',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        leading: IconButton( // Tombol kembali
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: _news.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "Belum ada berita komunitas",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16), 
              itemCount: _news.length,
              itemBuilder: (context, index) {
                final news = _news[index];
                final String imagePath = news['imagePath'] ?? '';
                final bool isAsset = imagePath.startsWith('assets/');
                final bool hasImage = imagePath.isNotEmpty && (isAsset || File(imagePath).existsSync());

                return Card(
                  margin: const EdgeInsets.only(bottom: 16), 
                  elevation: 5, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: InkWell( 
                    onTap: () {
                      _navigateToForm(existingNews: news);
                    },
                    borderRadius: BorderRadius.circular(15), 
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar Berita
                          if (hasImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10), 
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
                                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
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
                                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
                                          ),
                                        );
                                      },
                                    ),
                            )
                          else
                            Container( // Placeholder jika tidak ada gambar
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, size: 60, color: Colors.grey),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Judul Berita
                          Text(
                            news['title'] ?? 'Tidak ada Judul',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 8),

                          // Konten Berita (Deskripsi)
                          Text(
                            news['content'] ?? 'Tidak ada Konten',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                            maxLines: 3, // Batasi jumlah baris di tampilan daftar
                            overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika terlalu panjang
                          ),
                          const SizedBox(height: 12),

                          // Informasi Tambahan (Instansi, Tanggal) dan Tombol Aksi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: primaryColor), // Warna ikon edit
                                    tooltip: 'Edit Berita',
                                    onPressed: () => _navigateToForm(existingNews: news),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Hapus Berita',
                                    onPressed: () => _confirmDelete(news['id']), // Panggil fungsi konfirmasi hapus
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor, 
        child: const Icon(Icons.add, color: Colors.white), 
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}
