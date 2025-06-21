import 'dart:math';
import 'package:flutter/material.dart';
import 'news_article.dart';

class NewsService {
  static final Random _random = Random();

  static Map<String, List<NewsArticle>> _mockSpecializedNews = {
    'Polisi': [
      NewsArticle(
        title: 'Operasi Penindakan Kejahatan Jalanan Berhasil',
        description: 'Tim Satuan Reserse Kriminal berhasil mengamankan sekelompok pelaku kejahatan yang meresahkan masyarakat di wilayah perkotaan.',
        url: '',
        imageUrl: 'assets/polisi1.jpg',
        source: 'Kepolisian Daerah Metropolitan',
        publishedAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      NewsArticle(
        title: 'Sosialisasi Keamanan Lingkungan Sukses Digelar',
        description: 'Polisi setempat mengadakan kegiatan sosialisasi pencegahan tindak kriminalitas di kompleks perumahan dengan antusias warga yang tinggi.',
        url: '',
        imageUrl: 'assets/polisi2.jpg',
        source: 'Kepolisian Sektor Kota',
        publishedAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
      NewsArticle(
        title: 'Pengungkapan Sindikat Narkoba Lintas Kota',
        description: 'Satuan Narkoba berhasil mengungkap jaringan perdagangan narkoba yang telah beroperasi selama bertahun-tahun.',
        url: '',
        imageUrl: 'assets/polisi3.jpg',
        source: 'Kepolisian Daerah',
        publishedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
    ],
    'Pemadam Kebakaran': [
      NewsArticle(
        title: 'Pemadaman Kebakaran Gedung Perkantoran Berhasil',
        description: 'Tim pemadam kebakaran berhasil memadamkan api yang mengancam gedung perkantoran di pusat kota dalam waktu kurang dari satu jam.',
        url: '',
        imageUrl: 'assets/pemadam1.jpg',
        source: 'Dinas Pemadam Kebakaran Kota',
        publishedAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      NewsArticle(
        title: 'Pelatihan Pencegahan Kebakaran untuk Masyarakat',
        description: 'Dinas Pemadam Kebakaran menggelar workshop pencegahan dan penanganan kebakaran bagi warga dan pelaku usaha.',
        url: '',
        imageUrl: 'assets/pemadam2.jpg',
        source: 'Dinas Pemadam Kebakaran',
        publishedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      NewsArticle(
        title: 'Penyelamatan Warga dari Kebakaran Permukiman',
        description: 'Tim pemadam kebakaran berhasil mengevakuasi warga dan memadamkan api di permukiman padat penduduk.',
        url: '',
        imageUrl: 'assets/pemadam3.jpg',
        source: 'Unit Darurat Kebakaran',
        publishedAt: DateTime.now().subtract(Duration(hours: 6)),
      ),
    ],
    'Medis': [
      NewsArticle(
        title: 'Vaksinasi Massal COVID-19 Tahap Lanjutan',
        description: 'Rumah sakit setempat menggelar vaksinasi massal dengan target 5000 warga dalam sepekan.',
        url: '',
        imageUrl: 'assets/medis1.jpg',
        source: 'Dinas Kesehatan Kota',
        publishedAt: DateTime.now().subtract(Duration(hours: 4)),
      ),
      NewsArticle(
        title: 'Operasi Bedah Kompleks Berhasil Dilakukan',
        description: 'Tim medis berhasil melakukan operasi bedah kompleks pada pasien dengan kondisi kritis.',
        url: '',
        imageUrl: 'assets/medis2.jpg',
        source: 'Rumah Sakit Pusat',
        publishedAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      NewsArticle(
        title: 'Penyuluhan Kesehatan Masyarakat',
        description: 'Puskesmas mengadakan kegiatan penyuluhan kesehatan untuk meningkatkan kesadaran masyarakat akan pola hidup sehat.',
        url: '',
        imageUrl: 'assets/medis3.jpg',
        source: 'Puskesmas Kecamatan',
        publishedAt: DateTime.now().subtract(Duration(hours: 7)),
      ),
    ],
    'BPBD': [
      NewsArticle(
        title: 'Evakuasi Korban Banjir Berhasil Dilaksanakan',
        description: 'Tim BPBD berhasil mengevakuasi ratusan warga yang terdampak banjir di wilayah dataran rendah.',
        url: '',
        imageUrl: 'assets/bpbd1.jpg',
        source: 'BPBD Daerah',
        publishedAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
      NewsArticle(
        title: 'Mitigasi Bencana di Wilayah Rawan Longsor',
        description: 'BPBD melakukan survey dan pemasangan rambu peringatan di area rawan longsor.',
        url: '',
        imageUrl: 'assets/bpbd2.jpg',
        source: 'Pusat Mitigasi Bencana',
        publishedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      NewsArticle(
        title: 'Simulasi Penanganan Bencana Gempa',
        description: 'Dilakukan simulasi tanggap darurat untuk meningkatkan kesiapsiagaan masyarakat dalam menghadapi bencana gempa.',
        url: '',
        imageUrl: 'assets/bpbd3.jpg',
        source: 'BPBD Provinsi',
        publishedAt: DateTime.now().subtract(Duration(hours: 8)),
      ),
    ],
  };

  static Future<List<NewsArticle>> fetchArticles({
    String category = 'Polisi',
  }) async {
    // Simulasi delay untuk meniru proses pengambilan data
    await Future.delayed(Duration(seconds: 1));

    // Kembalikan mock data untuk kategori yang diminta
    List<NewsArticle> categoryArticles = _mockSpecializedNews[category] ?? [];
    
    // Acak urutan berita untuk variasi
    categoryArticles.shuffle();
    
    // Batasi jumlah berita (opsional)
    return categoryArticles.take(3).toList();
  }

  // Metode pencarian berita
  static Future<List<NewsArticle>> searchArticles({
    required String query,
  }) async {
    // Simulasi delay pencarian
    await Future.delayed(Duration(seconds: 1));

    // Kumpulkan semua artikel
    List<NewsArticle> allArticles = [];
    _mockSpecializedNews.values.forEach((categoryArticles) {
      allArticles.addAll(categoryArticles);
    });

    // Filter berdasarkan query
    return allArticles.where((article) => 
      article.title.toLowerCase().contains(query.toLowerCase()) ||
      article.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Metode untuk mendapatkan artikel terbaru
  static Future<NewsArticle?> getLatestArticle() async {
    // Kumpulkan semua artikel
    List<NewsArticle> allArticles = [];
    _mockSpecializedNews.values.forEach((categoryArticles) {
      allArticles.addAll(categoryArticles);
    });

    // Urutkan berdasarkan tanggal terbaru
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    // Kembalikan artikel paling baru
    return allArticles.isNotEmpty ? allArticles.first : null;
  }
}