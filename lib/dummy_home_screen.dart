import 'package:flutter/material.dart';

class DummyHomeScreen extends StatelessWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Dummy'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          '✅ Login berhasil!\nSelamat datang di halaman Dummy.',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
