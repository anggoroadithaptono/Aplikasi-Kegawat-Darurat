import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'package:flutter/gestures.dart'; 

class PilihUserScreen extends StatefulWidget {
  const PilihUserScreen({super.key});

  @override
  State<PilihUserScreen> createState() => _PilihUserScreenState();
}

class _PilihUserScreenState extends State<PilihUserScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas dengan logo dan judul
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 70),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih User untuk menjelajahi aplikasi kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Bagian menu user
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Menu User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Saya ingin masuk sebagai',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pilihan Masyarakat Kota
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'masyarakat';
                        });
                      },
                      child: Card(
                        color: selectedRole == 'masyarakat'
                            ? Colors.red.shade100
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: selectedRole == 'masyarakat'
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.location_city, color: Colors.red),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Masyarakat Kota',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Akses bagi warga masyarakat Kota',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pilihan Akun Instansi
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = 'instansi';
                        });
                      },
                      child: Card(
                        color: selectedRole == 'instansi'
                            ? Colors.red.shade100
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: selectedRole == 'instansi'
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance,
                                  color: Colors.red),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Akun Instansi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Akses untuk instansi terkait pertolongan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Link Butuh Bantuan
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Butuh Bantuan? ',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Klik Disini',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Arahkan ke halaman bantuan
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Tombol Lanjut
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedRole == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginScreen(role: selectedRole!),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
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
