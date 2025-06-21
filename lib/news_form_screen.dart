import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'database_helper.dart'; 

class NewsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNews;

  const NewsFormScreen({Key? key, this.existingNews}) : super(key: key);

  @override
  State<NewsFormScreen> createState() => _NewsFormScreenState();
}

class _NewsFormScreenState extends State<NewsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? imagePath;

  final ImagePicker _picker = ImagePicker();
  final Color primaryColor = const Color(0xFFC71811); 

  @override
  void initState() {
    super.initState();
    if (widget.existingNews != null) {
      titleController.text = widget.existingNews!['title'] ?? '';
      contentController.text = widget.existingNews!['content'] ?? '';
      imagePath = widget.existingNews!['imagePath'];
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  void _saveNews() async {
    if (!_formKey.currentState!.validate()) return;

    final db = DatabaseHelper();
    final newsData = {
      'title': titleController.text.trim(),
      'content': contentController.text.trim(),
      'imagePath': imagePath ?? '',
      'date': DateTime.now().toIso8601String(), 
      // 'instansi': 'Komunitas', // Dihapus: Default instansi untuk berita komunitas
    };

    try {
      if (widget.existingNews == null) {
        print("🔄 Menyimpan berita baru...");
        final id = await db.insertNews(newsData);
        print("✅ Disimpan dengan ID: $id");
      } else {
        print("✏️ Mengupdate berita dengan ID: ${widget.existingNews!['id']}");
        await db.updateNews(widget.existingNews!['id'], newsData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Berita berhasil disimpan",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating, 
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print("❌ Gagal menyimpan berita: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal menyimpan berita: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingNews == null ? "Unggah Cerita di Komunitas" : "Edit Cerita Komunitas",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Menggunakan SingleChildScrollView agar form bisa digulir
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Area Unggah Foto/Video
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15), // Sudut membulat
                    border: Border.all(color: Colors.grey.shade400, width: 1.5), // Border yang lebih halus
                  ),
                  child: imagePath != null && File(imagePath!).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14), // Sedikit lebih kecil dari container
                          child: Image.file(
                            File(imagePath!),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Gambar tidak ditemukan",
                                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                "Unggah Foto/Video",
                                style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              Text(
                "Judul *",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Kecelakaan Di Rungkut",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), 
                    borderSide: BorderSide.none, 
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                validator: (value) => value == null || value.isEmpty ? "Wajib isi judul" : null,
              ),
              const SizedBox(height: 20),

              // Deskripsi
              Text(
                "Deskripsi *",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: "Pada tanggal 14 April 2025, sekitar pukul 08:30 WIB...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? "Wajib isi deskripsi" : null,
              ),
              
              const SizedBox(height: 30),

              // Tombol Unggah/Simpan
              ElevatedButton(
                onPressed: _saveNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), 
                  ),
                  elevation: 5,
                ),
                child: Text(
                  widget.existingNews == null ? "Unggah" : "Simpan",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
