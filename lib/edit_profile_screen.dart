import 'package:flutter/material.dart';
import 'session.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: currentUser?['email'] ?? '');
    _roleController = TextEditingController(text: currentUser?['role'] ?? '');
  }

  void _saveProfile() {
    setState(() {
      currentUser?['email'] = _emailController.text.trim();
      currentUser?['role'] = _roleController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sunting Profil"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
