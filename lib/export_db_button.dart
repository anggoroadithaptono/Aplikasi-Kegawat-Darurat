import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class ExportDbButton extends StatelessWidget {
  const ExportDbButton({super.key});

  Future<void> _exportDb(BuildContext context) async {
    try {
      final dbPath = join(await getDatabasesPath(), 'myapp.db');
      final downloadDir = Directory('/storage/emulated/0/Download');
      final exportPath = join(downloadDir.path, 'myapp.db');

      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(exportPath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Database berhasil diekspor ke folder Download')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ File database tidak ditemukan')),
        );
      }
    } catch (e) {
      print("❌ Gagal ekspor: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyalin database')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _exportDb(context),
      icon: const Icon(Icons.download),
      label: const Text('Export DB ke Download'),
    );
  }
}
