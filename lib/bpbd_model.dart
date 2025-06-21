class BpbdModel {
  int? id;
  String lokasi;
  String uraian;
  String? jenisBencana;
  String? dampakKerusakan;
  int? jumlahPengungsi;
  String? bantuanDiberikan;
  String waktu;
  String jamMasuk;
  String status;
  String? fotoPath;

  BpbdModel({
    this.id,
    required this.lokasi,
    required this.uraian,
    this.jenisBencana,
    this.dampakKerusakan,
    this.jumlahPengungsi,
    this.bantuanDiberikan,
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
      'jenis_bencana': jenisBencana,
      'dampak_kerusakan': dampakKerusakan,
      'jumlah_pengungsi': jumlahPengungsi,
      'bantuan_diberikan': bantuanDiberikan,
      'waktu': waktu,
      'jamMasuk': jamMasuk,
      'status': status,
      'fotoPath': fotoPath,
    };
  }

  factory BpbdModel.fromMap(Map<String, dynamic> map) {
    return BpbdModel(
      id: map['id'],
      lokasi: map['lokasi'],
      uraian: map['uraian'],
      jenisBencana: map['jenis_bencana'],
      dampakKerusakan: map['dampak_kerusakan'],
      jumlahPengungsi: map['jumlah_pengungsi'],
      bantuanDiberikan: map['bantuan_diberikan'],
      waktu: map['waktu'],
      jamMasuk: map['jamMasuk'],
      status: map['status'],
      fotoPath: map['fotoPath'],
    );
  }
}