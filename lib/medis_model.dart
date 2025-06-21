class MedisModel {
  int? id;
  String lokasi;
  String uraian;
  String? jenisDarurat;
  int? jumlahKorban;
  String? kondisiPasien;
  String? penangananAwal;
  String waktu;
  String jamMasuk;
  String status;
  String? fotoPath;

  MedisModel({
    this.id,
    required this.lokasi,
    required this.uraian,
    this.jenisDarurat,
    this.jumlahKorban,
    this.kondisiPasien,
    this.penangananAwal,
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
      'jenis_darurat': jenisDarurat,
      'jumlah_korban': jumlahKorban,
      'kondisi_pasien': kondisiPasien,
      'penanganan_awal': penangananAwal,
      'waktu': waktu,
      'jamMasuk': jamMasuk,
      'status': status,
      'fotoPath': fotoPath,
    };
  }

  factory MedisModel.fromMap(Map<String, dynamic> map) {
    return MedisModel(
      id: map['id'],
      lokasi: map['lokasi'],
      uraian: map['uraian'],
      jenisDarurat: map['jenis_darurat'],
      jumlahKorban: map['jumlah_korban'],
      kondisiPasien: map['kondisi_pasien'],
      penangananAwal: map['penanganan_awal'],
      waktu: map['waktu'],
      jamMasuk: map['jamMasuk'],
      status: map['status'],
      fotoPath: map['fotoPath'],
    );
  }
}