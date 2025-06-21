// File: form_berita_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Untuk menyimpan gambar ke direktori aplikasi
import 'package:path/path.dart' as p;

import 'database_helper.dart';

class FormBeritaPage extends StatefulWidget {
  // Tambahkan parameter opsional untuk data berita (jika dalam mode edit)
  final Map<String, dynamic>? beritaData;

  const FormBeritaPage({super.key, this.beritaData});

  @override
  State<FormBeritaPage> createState() => _FormBeritaPageState();
}

class _FormBeritaPageState extends State<FormBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _instansiController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isEditing = false; // Untuk menentukan mode tambah atau edit

  @override
  void initState() {
    super.initState();
    if (widget.beritaData != null) {
      _isEditing = true;
      _instansiController.text = widget.beritaData!['instansi'] ?? '';
      _judulController.text = widget.beritaData!['judul'] ?? '';
      _deskripsiController.text = widget.beritaData!['deskripsi'] ?? '';
      _lokasiController.text = widget.beritaData!['lokasi'] ?? '';
      if (widget.beritaData!['media_path'] != null &&
          File(widget.beritaData!['media_path']).existsSync()) {
        _imageFile = File(widget.beritaData!['media_path']);
      }
    }
  }

  @override
  void dispose() {
    _instansiController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
      final String newPath = p.join(directory.path, fileName);
      final File newImage = await image.copy(newPath);
      return newImage.path;
    } catch (e) {
      print("Error saving image locally: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? savedImagePath;
      if (_imageFile != null) {
        // Hanya simpan jika ada gambar baru atau gambar lama tidak ada
        if (!_isEditing || widget.beritaData!['media_path'] != _imageFile!.path) {
           savedImagePath = await _saveImageLocally(_imageFile!);
        } else {
           savedImagePath = widget.beritaData!['media_path']; // Gunakan path lama jika tidak ada perubahan
        }
      } else {
        savedImagePath = null; // Jika gambar dihapus atau tidak ada
      }


      final Map<String, dynamic> newsData = {
        'instansi': _instansiController.text,
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _lokasiController.text,
        'media_path': savedImagePath,
        'tanggal': DateTime.now().toIso8601String(), // Tanggal saat berita dibuat/diedit
      };

      try {
        final dbHelper = DatabaseHelper();
        if (_isEditing && widget.beritaData!['id'] != null) {
          // Mode Edit
          await dbHelper.updateNewsInstansi(widget.beritaData!['id'], newsData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berita berhasil diperbarui', style: GoogleFonts.poppins())),
          );
        } else {
          // Mode Tambah Baru
          await dbHelper.insertNewsInstansi(newsData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berita berhasil ditambahkan', style: GoogleFonts.poppins())),
          );
        }
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
      } catch (e) {
        print("Error saving/updating news: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan berita: $e', style: GoogleFonts.poppins(color: Colors.white)), backgroundColor: Colors.red),
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
    const focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.0),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Berita' : 'Tambah Berita Baru',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Instansi", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instansiController,
                decoration: const InputDecoration(
                  hintText: 'Nama Instansi (misal: Kepolisian, Pemadam)',
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusedBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Instansi tidak boleh kosong';
                  }
                  return null;
                },
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text("Judul Berita", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  hintText: 'Judul berita',
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusedBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul berita tidak boleh kosong';
                  }
                  return null;
                },
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text("Deskripsi Berita", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Isi deskripsi berita',
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusedBorder,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi berita tidak boleh kosong';
                  }
                  return null;
                },
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text("Lokasi (Opsional)", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  hintText: 'Lokasi terkait berita (misal: Surabaya, Jawa Timur)',
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusedBorder,
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text("Gambar Berita", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[700]),
                            Text('Pilih Gambar', style: GoogleFonts.poppins(color: Colors.grey[700])),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _isEditing ? 'Perbarui Berita' : 'Tambah Berita',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}