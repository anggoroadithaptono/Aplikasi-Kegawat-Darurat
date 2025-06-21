import 'package:flutter/material.dart';

class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Departments'),
        backgroundColor: Colors.blue, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "List of Departments",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              // Tambahkan daftar departemen di sini
              const SizedBox(height: 20),
              // Bisa menambahkan list widget atau lainnya sesuai kebutuhan
            ],
          ),
        ),
      ),
    );
  }
}
