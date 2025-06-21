import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; 
import 'home_screen.dart'; 
import 'register_screen.dart';
import 'home_instansi.dart';
import 'database_helper.dart';
import 'export_db_button.dart';
import 'session.dart'; 


class LoginScreen extends StatefulWidget {
  final String role; 


  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controller untuk TabBar agar bisa beralih antara "Log In" dan "Sign Up".
  late TabController _tabController;
  // GlobalKey untuk mengelola state form dan melakukan validasi.
  final _formKey = GlobalKey<FormState>();
  // Controller untuk inputan teks email dan password.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Status loading untuk mengelola tampilan saat proses login berlangsung.
  bool isLoading = false;
  // Status checkbox "Ingat saya".
  bool rememberMe = false;

  // GestureRecognizer untuk menangani tap pada teks "Lupa Kata Sandi?".
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();

    // Menginisialisasi TabController dengan 2 tab (Log In, Sign Up).
    _tabController = TabController(length: 2, vsync: this);

    // Menambahkan listener pada TabController untuk menangani perpindahan tab.
    _tabController.addListener(() {
      // Memeriksa jika perpindahan tab sedang terjadi (bukan hanya memilih tab yang sama).
      if (_tabController.indexIsChanging) {
        // Jika tab yang dipilih adalah tab "Sign Up" (indeks 1).
        if (_tabController.index == 1) {
          // Menunda navigasi hingga frame berikutnya selesai dirender.
          // Ini mencegah error "setState() or markNeedsBuild() called during build".
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Melakukan navigasi ke SignUpScreen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignUpScreen(role: widget.role),
              ),
            ).then((_) {
              // Setelah kembali dari SignUpScreen, kembalikan tab ke "Log In" (indeks 0).
              _tabController.index = 0;
            });
          });
        }
      }
    });

    // Menginisialisasi TapGestureRecognizer untuk teks "Lupa Kata Sandi?".
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        // Logika yang akan dijalankan saat teks ditekan.
        print('Lupa Kata Sandi ditekan');
        // TODO: Implementasi navigasi ke layar Lupa Kata Sandi
      };
  }

  @override
  void dispose() {
    // Membuang semua controller dan gesture recognizer untuk menghindari memory leak.
    _tabController.dispose();
    _tapGestureRecognizer.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menangani proses login pengguna.
  /// Melakukan validasi form, otentikasi pengguna dari database,
  /// dan navigasi ke layar yang sesuai.
  void _login() async {
    // Memvalidasi form. Jika tidak valid, hentikan proses.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mengubah status loading menjadi true untuk menampilkan indikator loading.
    setState(() => isLoading = true);
    // Mengambil instance DatabaseHelper.
    final db = DatabaseHelper();
    // Mengambil email, password, dan peran dari controller dan properti widget.
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final role = widget.role.trim().toLowerCase();

    try {
      // Mengambil semua pengguna dari database.
      final users = await db.getUsers();

      // Mencari pengguna yang cocok berdasarkan email, password, dan peran.
      final user = users.firstWhere(
        (u) =>
            u['email'] == email &&
            u['password'] == password &&
            u['role'].toString().toLowerCase() == role,
        orElse: () => {}, // Jika tidak ditemukan, kembalikan map kosong.
      );

      // Memeriksa apakah pengguna ditemukan.
      if (user.isNotEmpty) {
        // Menyimpan data pengguna yang login ke session.
        currentUser = user;

        // Menampilkan snackbar bahwa login berhasil.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil')),
        );

        // Melakukan navigasi berdasarkan peran pengguna.
        if (role == 'masyarakat') {
          // Ganti layar saat ini dengan HomeScreen.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (role == 'instansi') {
          // Ganti layar saat ini dengan HomeInstansi.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeInstansi()),
          );
        }
      } else {
        // Jika pengguna tidak ditemukan, tampilkan pesan error.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal: email atau password salah')), // Pesan lebih spesifik
        );
      }
    } catch (e) {
      // Menangani kesalahan umum saat proses login.
      print("❌ Terjadi kesalahan saat login: $e"); // Cetak error untuk debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat login')),
      );
    } finally {
      // Pastikan status loading kembali ke false, terlepas dari keberhasilan atau kegagalan.
      setState(() => isLoading = false);
    }
  }

  /// Fungsi navigasi ke layar registrasi (SignUpScreen).
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignUpScreen(role: widget.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendefinisikan radius border yang sering digunakan.
    final borderRadius = BorderRadius.circular(10);

    return Scaffold(
      backgroundColor: Colors.red.shade900, // Warna latar belakang keseluruhan
      body: SafeArea(
        child: Column(
          children: [
            // Bagian Header dengan logo dan teks selamat datang
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
                  // Judul selamat datang
                  const Text(
                    'Selamat Datang...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle ajakan masuk
                  const Text(
                    'Masuk untuk menjelajahi aplikasi kami',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Konten form dengan background putih dan TabBar
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // Border radius hanya di bagian atas untuk efek melengkung
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // TabBar untuk beralih antara Login dan Sign Up
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.red,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      tabs: const [
                        Tab(text: 'Log In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // TabBarView untuk menampilkan konten tab yang berbeda
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Konten Form Login
                          SingleChildScrollView(
                            child: Form(
                              key: _formKey, // Mengaitkan GlobalKey dengan Form
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TextFormField untuk Email
                                  TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Masukkan Nama Email',
                                      border: OutlineInputBorder(
                                        borderRadius: borderRadius,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    // Validator untuk email: memastikan tidak kosong.
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Email wajib diisi'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  // TextFormField untuk Kata Sandi (Password)
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText:
                                        true, // Menyembunyikan teks password
                                    decoration: InputDecoration(
                                      labelText: 'Kata Sandi',
                                      hintText: 'Masukkan Kata Sandi',
                                      border: OutlineInputBorder(
                                        borderRadius: borderRadius,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                    ),
                                    // Validator untuk password: memastikan tidak kosong.
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Password wajib diisi'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  // Baris untuk Checkbox "Ingat saya" dan teks "Lupa Kata Sandi?"
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Checkbox "Ingat saya"
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: rememberMe,
                                            activeColor: Colors.red,
                                            onChanged: (val) {
                                              setState(() {
                                                rememberMe = val ?? false;
                                              });
                                            },
                                          ),
                                          const Text('Ingat saya'),
                                        ],
                                      ),
                                      // Teks "Lupa Kata Sandi?" dengan TapGestureRecognizer
                                      RichText(
                                        text: TextSpan(
                                          text: 'Lupa Kata Sandi ?',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          // Mengaitkan gesture recognizer
                                          recognizer: _tapGestureRecognizer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Tombol "Masuk" (Login)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      // Nonaktifkan tombol jika sedang loading
                                      onPressed: isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // Warna tombol
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadius,
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors
                                                  .white) // Indikator loading
                                          : const Text(
                                              'Masuk',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Garis pemisah dengan teks "Atau"
                                  Row(
                                    children: [
                                      const Expanded(
                                          child: Divider(thickness: 1)),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          'Atau',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                          child: Divider(thickness: 1)),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Tombol "Lanjutkan dengan Google"
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      icon: Image.asset(
                                        'assets/google_logo.png', // Pastikan logo ini ada di assets
                                        height: 24,
                                        width: 24,
                                      ),
                                      label: const Text(
                                        'Lanjutkan dengan Google',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14),
                                      ),
                                      onPressed: () {
                                        // TODO: Implementasi login dengan Google
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Colors.grey),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadius,
                                        ),
                                        backgroundColor: Colors.grey
                                            .shade100, // Warna latar belakang tombol
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Placeholder untuk halaman Sign Up di TabBarView.
                          // Navigasi ke SignUpScreen sudah ditangani oleh TabController listener.
                          Center(
                            child: Text(
                              'Silakan gunakan tab "Sign Up" untuk mendaftar',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16),
                              textAlign: TextAlign.center,
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
