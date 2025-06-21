import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Bahasa"),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Bahasa Indonesia"),
            onTap: () {
              // Nanti bisa tambahkan pengaturan bahasa di sini
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bahasa Indonesia dipilih")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("English"),
            onTap: () {
              // Nanti bisa tambahkan pengaturan bahasa di sini
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("English selected")),
              );
            },
          ),
        ],
      ),
    );
  }
}
