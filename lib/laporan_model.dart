import 'dart:io';

class LaporanModel {
  final int? id;
  final String lokasi;
  final String instansi;
  final String uraian;
  final String role;
  final String waktu; 
  final String jamMasuk; 
  final String status;
  final String? fotoPath;

  LaporanModel({
    this.id,
    required this.lokasi,
    required this.instansi,
    required this.uraian,
    required this.role,
    required this.waktu,
    required this.jamMasuk,
    required this.status,
    this.fotoPath,
  });

  // Metode untuk mengkonversi LaporanModel menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lokasi': lokasi,
      'instansi': instansi,
      'uraian': uraian,
      'role': role,
      'waktu': waktu,
      'jamMasuk': jamMasuk,
      'status': status,
      'fotoPath': fotoPath,
    };
  }

  // Metode untuk membuat LaporanModel dari Map yang diambil dari database
  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    return LaporanModel(
      id: map['id'] as int?,
      lokasi: map['lokasi'] as String,
      instansi: map['instansi'] as String,
      uraian: map['uraian'] as String,
      role: map['role'] as String,
      waktu: map['waktu'] as String,
      jamMasuk: map['jamMasuk'] as String,
      status: map['status'] as String,
      fotoPath: map['fotoPath'] as String?,
    );
  }
}
