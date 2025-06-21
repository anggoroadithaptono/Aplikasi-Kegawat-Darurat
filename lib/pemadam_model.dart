class PemadamModel {
  int? id;
  String lokasi;
  String uraian;
  String? jenisKebakaran;
  int? korbanJiwa;
  String? kerugianEstimasi;
  String waktu;
  String jamMasuk;
  String status;
  String? fotoPath;

  PemadamModel({
    this.id,
    required this.lokasi,
    required this.uraian,
    this.jenisKebakaran,
    this.korbanJiwa,
    this.kerugianEstimasi,
    required this.waktu,
    required this.jamMasuk,
    required this.status,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lokasi': lokasi,
      'uraian': uraian,
      'jenis_kebakaran': jenisKebakaran,
      'korban_jiwa': korbanJiwa,
      'kerugian_estimasi': kerugianEstimasi,
      'waktu': waktu,
      'jamMasuk': jamMasuk,
      'status': status,
      'fotoPath': fotoPath,
    };
  }

  factory PemadamModel.fromMap(Map<String, dynamic> map) {
    return PemadamModel(
      id: map['id'],
      lokasi: map['lokasi'],
      uraian: map['uraian'],
      jenisKebakaran: map['jenis_kebakaran'],
      korbanJiwa: map['korban_jiwa'],
      kerugianEstimasi: map['kerugian_estimasi'],
      waktu: map['waktu'],
      jamMasuk: map['jamMasuk'],
      status: map['status'],
      fotoPath: map['fotoPath'],
    );
  }
}