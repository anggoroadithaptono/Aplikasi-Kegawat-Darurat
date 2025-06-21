import 'package:flutter/material.dart';

class DetailProfilePage extends StatelessWidget {
  const DetailProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: Text("Detail Profil"), backgroundColor: Colors.blue),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: Anggoro Adit Haptono", style: TextStyle(fontSize: 18)),
              Text("Universitas: UPN Veteran Jawa Timur", style: TextStyle(fontSize: 18)),
              Text("Bidang: Sistem Informasi", style: TextStyle(fontSize: 18)),
              Text("Keahlian: Manajemen Server, Jaringan, Pengembangan Web", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Kembali"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}