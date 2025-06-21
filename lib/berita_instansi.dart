import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'form_berita_page.dart';
import 'database_helper.dart';
import 'detail_berita_page.dart';

class BeritaInstansiPage extends StatefulWidget {
  const BeritaInstansiPage({super.key});

  @override
  State<BeritaInstansiPage> createState() => _BeritaInstansiPageState();
}

class _BeritaInstansiPageState extends State<BeritaInstansiPage> {
  List<Map<String, dynamic>> beritaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await DatabaseHelper().getAllNewsInstansi();
      setState(() {
        beritaList = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading news: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat berita: $e")),
      );
    }
  }

  Future<void> _deleteBerita(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Konfirmasi Hapus", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus berita ini?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper().deleteNewsInstansi(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berita berhasil dihapus", style: GoogleFonts.poppins())),
        );
        _loadBerita();
      } catch (e) {
        print("Error deleting news: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus berita: $e", style: GoogleFonts.poppins())),
        );
      }
    }
  }

  Future<void> _editBerita(Map<String, dynamic> berita) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormBeritaPage(beritaData: berita),
      ),
    );
    _loadBerita();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Berita Instansi',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Topic Favorit",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBeritaPage(
                            berita: {
                              'judul': "BMKG rilis peringatan dini 3 harian\nagar masyarakat waspada bepergian",
                              'deskripsi': "Badan Meteorologi, Klimatologi, dan Geofisika (BMKG) telah merilis peringatan dini cuaca ekstrem selama tiga hari ke depan, mengimbau masyarakat untuk meningkatkan kewaspadaan, terutama bagi yang berencana bepergian. Curah hujan tinggi dan angin kencang diprediksi akan terjadi di beberapa wilayah. BMKG menyarankan untuk selalu memantau informasi cuaca terbaru dari sumber resmi dan menyiapkan langkah-langkah mitigasi.",
                              'media_path': 'assets/berita2.jpg',
                              'instansi': 'BMKG',
                              'tanggal': '2023-12-23T00:00:00.000',
                            },
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/berita2.jpg',
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              "BMKG rilis peringatan dini 3 harian\nagar masyarakat waspada bepergian",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Berita Terbaru Instansi",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  beritaList.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              'Belum ada berita yang ditambahkan.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: beritaList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            final berita = beritaList[index];
                            return _buildBeritaCard(berita);
                          },
                        )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormBeritaPage()),
          );
          _loadBerita();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // === MODIFIKASI FUNGSI _buildBeritaCard ===
  Widget _buildBeritaCard(Map<String, dynamic> berita) {
    final String title = berita['judul'] ?? 'Tidak ada judul';
    final String? imagePath = berita['media_path'];
    final bool isAsset = imagePath != null && imagePath.startsWith('assets/');
    final bool hasValidFile = imagePath != null && File(imagePath).existsSync();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column( // Ubah dari InkWell ke Column untuk menempatkan aksi di bawah
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( // Expanded agar gambar mengambil sisa ruang yang tersedia
            child: InkWell( // Bungkus konten utama dengan InkWell untuk onTap
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailBeritaPage(berita: berita),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: isAsset
                        ? Image.asset(
                            imagePath!,
                            height: double.infinity, // Isi tinggi yang tersedia
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : hasValidFile
                            ? Image.file(
                                File(imagePath!),
                                height: double.infinity, // Isi tinggi yang tersedia
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/placeholder.jpg',
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/placeholder.jpg',
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                  ),
                  // Hapus Positioned PopupMenuButton di sini
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${berita['instansi'] ?? 'Instansi Tidak Diketahui'} - ${berita['tanggal'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(berita['tanggal'])) : 'Tanggal Tidak Diketahui'}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // === TAMBAHKAN BARIS INI UNTUK AKSI EDIT/HAPUS LANGSUNG ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Warna background untuk bar aksi
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Rata tengah dengan spasi
              children: [
                // Tombol Edit
                InkWell(
                  onTap: () {
                    if (berita['id'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID berita tidak valid untuk edit.')));
                      return;
                    }
                    _editBerita(berita);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text("Edit", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                // Divider opsional
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Tombol Hapus
                InkWell(
                  onTap: () {
                    if (berita['id'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID berita tidak valid untuk hapus.')));
                      return;
                    }
                    _deleteBerita(berita['id'] as int);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text("Hapus", style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // === AKHIR TAMBAHAN ===
        ],
      ),
    );
  }
}