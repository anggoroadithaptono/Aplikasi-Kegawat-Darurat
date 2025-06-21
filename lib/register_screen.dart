import 'package:flutter/material.dart';
import 'database_helper.dart'; 


class SignUpScreen extends StatefulWidget {
  final String role; // Peran pengguna (misalnya, 'admin', 'user')


  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controller untuk inputan teks email, password, dan konfirmasi password.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // GlobalKey untuk mengelola state form dan melakukan validasi.
  final _formKey = GlobalKey<FormState>();

  // Status loading untuk mengelola tampilan saat proses registrasi berlangsung.
  bool isLoading = false;


  void _signUp() async {
    // Memvalidasi form. Jika tidak valid, hentikan proses.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mengubah status loading menjadi true untuk menampilkan indikator loading.
    setState(() => isLoading = true);

    // Mengambil nilai email dan password dari controller,
    // lalu membersihkan spasi dan mengubah email menjadi huruf kecil.
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    // Membuat instance dari DatabaseHelper untuk interaksi dengan database.
    final db = DatabaseHelper();

    try {
      // Mengambil daftar pengguna yang sudah ada dari database.
      final existingUsers = await db.getUsers();
      // Memeriksa apakah email yang dimasukkan sudah terdaftar.
      final alreadyExists = existingUsers.any((u) => u['email'] == email);

      if (alreadyExists) {
        // Jika email sudah terdaftar, tampilkan snackbar dan hentikan proses.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sudah terdaftar')),
        );
        setState(() => isLoading = false); // Mengembalikan status loading
        return;
      }

      // Jika email belum terdaftar, masukkan data pengguna baru ke database.
      await db.insertUser({
        'email': email,
        'password': password,
        'role': widget.role, // Menyimpan peran pengguna
      });

      // Tampilkan snackbar bahwa registrasi berhasil.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil!')),
      );

      // Kembali ke layar sebelumnya setelah registrasi berhasil.
      Navigator.pop(context);
    } catch (e) {
      // Menangani kesalahan yang terjadi selama proses registrasi.
      // Cetak error ke konsol untuk debugging.
      print("❌ Gagal registrasi: $e");
      // Tampilkan snackbar dengan pesan error yang lebih umum kepada pengguna.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat registrasi')),
      );
    } finally {
      // Pastikan status loading kembali ke false, terlepas dari keberhasilan atau kegagalan.
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    // Pastikan semua TextEditingController dibuang untuk menghindari memory leak.
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendefinisikan radius border yang sering digunakan.
    final borderRadius = BorderRadius.circular(12);

    return Scaffold(
      backgroundColor: Colors.red.shade900, // Warna latar belakang keseluruhan
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Header dengan judul dan subtitle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                // Gradient warna untuk header
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Logo aplikasi
                  Image.asset('assets/logo.png', height: 50),
                  const SizedBox(height: 20),
                  // Judul layar
                  const Text(
                    'Registrasi Akun',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle yang menunjukkan peran pengguna
                  Text(
                    'Daftar sebagai ${widget.role}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Bagian Form registrasi dalam container putih melengkung
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // Border radius hanya di bagian atas untuk efek melengkung
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  children: [
                    Form(
                      key: _formKey, // Mengaitkan GlobalKey dengan Form
                      child: Column(
                        children: [
                          // TextFormField untuk Email
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: borderRadius,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            // Validator untuk email: memastikan tidak kosong.
                            validator: (v) => v == null || v.isEmpty
                                ? 'Email wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // TextFormField untuk Password
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: borderRadius,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            obscureText: true, // Menyembunyikan teks password
                            // Validator untuk password: memastikan tidak kosong.
                            validator: (v) => v == null || v.isEmpty
                                ? 'Password wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // TextFormField untuk Konfirmasi Password
                          TextFormField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              border: OutlineInputBorder(
                                borderRadius: borderRadius,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            obscureText: true, // Menyembunyikan teks
                            // Validator untuk konfirmasi password: memastikan cocok dengan password.
                            validator: (v) => v != passwordController.text
                                ? 'Password tidak cocok'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              // Nonaktifkan tombol jika sedang loading
                              onPressed: isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Warna tombol
                                shape: RoundedRectangleBorder(
                                  borderRadius: borderRadius,
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white) // Indikator loading
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
