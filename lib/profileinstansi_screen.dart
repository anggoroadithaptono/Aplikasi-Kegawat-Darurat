import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts untuk konsistensi gaya teks
import 'session.dart'; 
import 'edit_profile_screen.dart'; 
import 'change_password_screen.dart'; 
import 'language_selection_screen.dart'; 


class ProfilPenggunaPage extends StatelessWidget {
  const ProfilPenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.red, // Warna AppBar
        elevation: 0, // Hapus bayangan AppBar
        centerTitle: true, // Pusatkan judul
      ),
      body: user == null
          ? Center(
              // Tampilkan pesan jika pengguna tidak ditemukan (misalnya, belum login).
              child: Text(
                "Pengguna tidak ditemukan",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),

                // --- Bagian: Akun ---
                // Header untuk bagian Akun dengan ikon dan teks.
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[800], size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "Akun",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1.5, color: Colors.grey),
                // Opsi "Sunting Profil".
                ListTile(
                  title: Text(
                    "Sunting Profil",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  // Menampilkan email pengguna sebagai subtitle.
                  subtitle: Text(
                    user['email'] ?? '-',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // Navigasi ke layar EditProfileScreen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                // Opsi "Ubah Kata Sandi".
                ListTile(
                  title: Text(
                    "Ubah Kata Sandi",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // Navigasi ke layar ChangePasswordScreen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),

                const SizedBox(height: 30), // Spasi antar bagian

                // --- Bagian: Sistem ---
                // Header untuk bagian Sistem dengan ikon dan teks.
                Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey[800], size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "Sistem",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1.5, color: Colors.grey),
                // Opsi "Bahasa".
                ListTile(
                  title: Text(
                    "Bahasa",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    // Navigasi ke layar LanguageSelectionScreen.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen()),
                    );
                  },
                ),
                // Opsi "Bantuan".
                ListTile(
                    title: Text(
                      "Bantuan",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // TODO: Implementasi navigasi ke halaman bantuan
                    }),
                // Opsi "Kebijakan Privasi".
                ListTile(
                    title: Text(
                      "Kebijakan Privasi",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // TODO: Implementasi navigasi ke halaman kebijakan privasi
                    }),
                // Opsi "Versi".
                ListTile(
                    title: Text(
                      "Versi Aplikasi",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: Text(
                      "1.0.0", // Contoh nomor versi, bisa diganti dinamis
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                    onTap: () {
                      // TODO: Tampilkan dialog informasi versi aplikasi
                    }),

                const SizedBox(height: 30), // Spasi antar bagian

                // --- Bagian: Notifikasi ---
                // Header untuk bagian Notifikasi dengan ikon dan teks.
                Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.grey[800], size: 24),
                    const SizedBox(width: 10),
                    Text(
                      "Notifikasi",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1.5, color: Colors.grey),
                // Opsi "Rekomendasi" (bisa diubah menjadi toggle notifikasi atau pengaturan lainnya).
                ListTile(
                    title: Text(
                      "Rekomendasi",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // TODO: Implementasi pengaturan notifikasi rekomendasi
                    }),

                const SizedBox(height: 40), // Spasi sebelum tombol Logout

                // --- Tombol Logout ---
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Warna tombol logout
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 5, // Tambah sedikit bayangan untuk tombol
                    ),
                    onPressed: () {
                      // Mengatur `currentUser` menjadi null untuk mengakhiri sesi.
                      currentUser = null;
                      // Kembali ke layar sebelumnya (biasanya layar login atau home utama).
                      Navigator.pop(context);
                      // Opsional: Tampilkan pesan logout berhasil
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Anda telah berhasil keluar.",
                              style: GoogleFonts.poppins()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.white), // Ikon logout
                    label: Text("Keluar",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }
}
