import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'session.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  void _saveNewPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom wajib diisi")),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata sandi tidak cocok")),
      );
      return;
    }

    if (currentUser == null || currentUser!['email'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada data pengguna yang valid")),
      );
      return;
    }

    try {
      final db = await dbHelper.database;
      await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [currentUser!['email']],
      );
      currentUser!['password'] = newPassword;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata sandi berhasil diperbarui")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui kata sandi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Kata Sandi"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata Sandi Baru'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi Kata Sandi'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveNewPassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
