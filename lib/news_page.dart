import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Latest News"),
        backgroundColor: Colors.blue, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "News Content Here",
              style: TextStyle(fontSize: 20),
            ),
            // Tambahkan konten berita di sini
          ],
        ),
      ),
    );
  }
}
