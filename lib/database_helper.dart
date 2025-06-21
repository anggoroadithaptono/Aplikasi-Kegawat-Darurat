import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'laporan_model.dart';


class DatabaseHelper {
  // Singleton instance untuk memastikan hanya ada satu objek DatabaseHelper.
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  /// Private constructor untuk inisialisasi internal (digunakan oleh singleton).
  DatabaseHelper._internal();


  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'myapp.db');

    try {
    
      return await openDatabase(
        path,
        version: 10,
        onCreate: _onCreate, // Dipanggil saat database pertama kali dibuat
        onUpgrade: _onUpgrade, // Dipanggil saat versi database berubah
      );
    } on DatabaseException catch (e) {
      // Menangani kasus di mana database mungkin dalam keadaan read-only
      if (e.toString().contains('read-only')) {
        print(
            "Error: Database read-only during initial open. Attempting to delete and re-create.");
        // Tutup database jika terbuka sebelum mencoba menghapus dan membuat ulang
        if (_database != null && _database!.isOpen) {
          await _database!.close();
          _database = null;
        }
        // Hapus dan inisialisasi ulang database
        await resetDatabase();
        return await database; // Coba dapatkan database lagi setelah reset
      }
      rethrow; // Lempar ulang error jika bukan karena read-only
    }
  }

  /// --- Metode onCreate: Dipanggil saat database pertama kali dibuat ---
  Future _onCreate(Database db, int version) async {
    // Membuat tabel USERS untuk menyimpan data pengguna (email, password, role)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE, -- Menambahkan UNIQUE untuk email
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
    print("Tabel 'users' berhasil dibuat.");

    // Membuat tabel NEWS untuk menyimpan berita atau informasi umum
    await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT,
        date TEXT NOT NULL
      )
    ''');
    print("Tabel 'news' berhasil dibuat.");

    // Membuat tabel LAPORAN (Umum, bisa tetap digunakan untuk laporan Kepolisian)
    await db.execute('''
      CREATE TABLE laporan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lokasi TEXT NOT NULL,
        instansi TEXT NOT NULL, -- Contoh: 'Kepolisian'
        uraian TEXT NOT NULL,
        role TEXT NOT NULL,
        waktu TEXT NOT NULL,
        jamMasuk TEXT NOT NULL,
        status TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    print("Tabel 'laporan' berhasil dibuat.");

    // Membuat tabel NEWS_INSTANSI untuk berita spesifik per instansi
    await db.execute('''
      CREATE TABLE news_instansi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        instansi TEXT NOT NULL,
        judul TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        lokasi TEXT,
        media_path TEXT,
        tanggal TEXT NOT NULL
      )
    ''');
    print("Tabel 'news_instansi' berhasil dibuat.");

    // Membuat tabel PEMADAM untuk laporan terkait pemadam kebakaran
    await db.execute('''
      CREATE TABLE pemadam (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lokasi TEXT NOT NULL,
        uraian TEXT NOT NULL,
        jenis_kebakaran TEXT, -- Contoh: 'bangunan', 'lahan', 'kendaraan'
        korban_jiwa INTEGER DEFAULT 0,
        kerugian_estimasi TEXT,
        waktu TEXT NOT NULL,
        jamMasuk TEXT NOT NULL,
        status TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    print("Tabel 'pemadam' berhasil dibuat.");

    // Membuat tabel MEDIS untuk laporan terkait kondisi medis/kesehatan darurat
    await db.execute('''
      CREATE TABLE medis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lokasi TEXT NOT NULL,
        uraian TEXT NOT NULL,
        jenis_darurat TEXT, -- Contoh: 'kecelakaan', 'sakit_mendadak', 'bencana_alam'
        jumlah_korban INTEGER DEFAULT 0,
        kondisi_pasien TEXT, -- Contoh: 'stabil', 'kritis', 'meninggal'
        penanganan_awal TEXT,
        waktu TEXT NOT NULL,
        jamMasuk TEXT NOT NULL,
        status TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    print("Tabel 'medis' berhasil dibuat.");

    // Membuat tabel BPBD untuk laporan terkait Badan Penanggulangan Bencana Daerah
    await db.execute('''
      CREATE TABLE bpbd (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lokasi TEXT NOT NULL,
        uraian TEXT NOT NULL,
        jenis_bencana TEXT, -- Contoh: 'banjir', 'longsor', 'gempa', 'puting_beliung'
        dampak_kerusakan TEXT,
        jumlah_pengungsi INTEGER DEFAULT 0,
        bantuan_diberikan TEXT,
        waktu TEXT NOT NULL,
        jamMasuk TEXT NOT NULL,
        status TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
    print("Tabel 'bpbd' berhasil dibuat.");
  }

  /// --- Metode onUpgrade: Dipanggil saat versi database berubah ---
  /// Metode ini menangani migrasi skema database dari versi lama ke versi baru.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Melakukan upgrade database dari versi $oldVersion ke $newVersion");

    // Contoh migrasi: Menambahkan kolom 'jamMasuk' dan 'fotoPath' jika versi lama kurang dari 9.
    if (oldVersion < 9) {
      try {
        await db.execute("ALTER TABLE laporan ADD COLUMN IF NOT EXISTS jamMasuk TEXT;");
        print("Kolom 'jamMasuk' ditambahkan ke tabel 'laporan'.");
      } catch (e) {
        print("Gagal menambahkan kolom 'jamMasuk' ke tabel 'laporan': $e");
      }
      try {
        await db.execute("ALTER TABLE laporan ADD COLUMN IF NOT EXISTS fotoPath TEXT;");
        print("Kolom 'fotoPath' ditambahkan ke tabel 'laporan'.");
      } catch (e) {
        print("Gagal menambahkan kolom 'fotoPath' ke tabel 'laporan': $e");
      }
    }

    // Pastikan tabel pemadam, medis, bpbd dibuat jika belum ada.
    // Ini penting jika pengguna mengupgrade aplikasi dari versi lama yang belum punya tabel ini.
    if (oldVersion < 10) {
      // Membuat tabel 'pemadam' jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pemadam (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lokasi TEXT NOT NULL,
          uraian TEXT NOT NULL,
          jenis_kebakaran TEXT,
          korban_jiwa INTEGER DEFAULT 0,
          kerugian_estimasi TEXT,
          waktu TEXT NOT NULL,
          jamMasuk TEXT NOT NULL,
          status TEXT NOT NULL,
          fotoPath TEXT
        )
      ''');
      print("Tabel 'pemadam' diperiksa/dibuat.");

      // Membuat tabel 'medis' jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medis (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lokasi TEXT NOT NULL,
          uraian TEXT NOT NULL,
          jenis_darurat TEXT,
          jumlah_korban INTEGER DEFAULT 0,
          kondisi_pasien TEXT,
          penanganan_awal TEXT,
          waktu TEXT NOT NULL,
          jamMasuk TEXT NOT NULL,
          status TEXT NOT NULL,
          fotoPath TEXT
        )
      ''');
      print("Tabel 'medis' diperiksa/dibuat.");

      // Membuat tabel 'bpbd' jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bpbd (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lokasi TEXT NOT NULL,
          uraian TEXT NOT NULL,
          jenis_bencana TEXT,
          dampak_kerusakan TEXT,
          jumlah_pengungsi INTEGER DEFAULT 0,
          bantuan_diberikan TEXT,
          waktu TEXT NOT NULL,
          jamMasuk TEXT NOT NULL,
          status TEXT NOT NULL,
          fotoPath TEXT
        )
      ''');
      print("Tabel 'bpbd' diperiksa/dibuat.");
    }
  }

  /// --- Operasi CRUD untuk Tabel USERS ---
  /// Memasukkan data pengguna baru ke tabel 'users'.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  /// Mengambil semua data pengguna dari tabel 'users'.
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  /// --- Operasi CRUD untuk Tabel NEWS ---
  /// Memasukkan data berita baru ke tabel 'news'.
  Future<int> insertNews(Map<String, dynamic> news) async {
    final db = await database;
    return await db.insert('news', news);
  }

  /// Mengambil semua data berita dari tabel 'news', diurutkan berdasarkan tanggal.
  Future<List<Map<String, dynamic>>> getNews() async {
    final db = await database;
    return await db.query('news', orderBy: 'date DESC');
  }

  /// Memperbarui data berita yang ada di tabel 'news' berdasarkan ID.
  Future<int> updateNews(int id, Map<String, dynamic> news) async {
    final db = await database;
    return await db.update('news', news, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus data berita dari tabel 'news' berdasarkan ID.
  Future<int> deleteNews(int id) async {
    final db = await database;
    return await db.delete('news', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Operasi CRUD untuk Tabel LAPORAN (Laporan Umum/Kepolisian) ---
  /// Memasukkan data laporan baru ke tabel 'laporan'.
  Future<int> insertLaporan(LaporanModel laporan) async {
    final db = await database;
    return await db.insert('laporan', laporan.toMap());
  }

  /// Mengambil semua data laporan dari tabel 'laporan', diurutkan berdasarkan waktu.
  Future<List<Map<String, dynamic>>> getAllLaporan() async {
    try {
      final db = await database;
      return await db.query('laporan', orderBy: 'waktu DESC');
    } on DatabaseException catch (e) {
      if (e.toString().contains('read-only')) {
        print("Error: Database read-only during getAllLaporan. Attempting to reset and retry query.");
        if (_database != null && _database!.isOpen) {
          await _database!.close();
          _database = null;
        }
        await resetDatabase();
        final newDb = await database;
        return await newDb.query('laporan', orderBy: 'waktu DESC');
      }
      rethrow;
    }
  }

  /// Memperbarui data laporan yang ada di tabel 'laporan' berdasarkan ID.
  Future<int> updateLaporan(int id, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.update('laporan', data, where: 'id = ?', whereArgs: [id]);
    } on DatabaseException catch (e) {
      if (e.toString().contains('read-only')) {
        print("Error: Database read-only. Attempting to reset and retry update.");
        if (_database != null && _database!.isOpen) {
          await _database!.close();
          _database = null;
        }
        await resetDatabase();
        final newDb = await database;
        return await newDb.update('laporan', data, where: 'id = ?', whereArgs: [id]);
      }
      rethrow;
    }
  }

  /// Menghapus data laporan dari tabel 'laporan' berdasarkan ID.
  Future<int> deleteLaporan(int id) async {
    try {
      final db = await database;
      return await db.delete('laporan', where: 'id = ?', whereArgs: [id]);
    } on DatabaseException catch (e) {
      if (e.toString().contains('read-only')) {
        print("Error: Database read-only. Attempting to reset and retry delete.");
        if (_database != null && _database!.isOpen) {
          await _database!.close();
          _database = null;
        }
        await resetDatabase();
        final newDb = await database;
        return await newDb.delete('laporan', where: 'id = ?', whereArgs: [id]);
      }
      rethrow;
    }
  }

  /// --- Operasi CRUD untuk Tabel NEWS_INSTANSI ---
  /// Memasukkan data berita instansi baru ke tabel 'news_instansi'.
  Future<int> insertNewsInstansi(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('news_instansi', data);
  }

  /// Mengambil semua data berita instansi dari tabel 'news_instansi', diurutkan berdasarkan tanggal.
  Future<List<Map<String, dynamic>>> getAllNewsInstansi() async {
    final db = await database;
    return await db.query('news_instansi', orderBy: 'tanggal DESC');
  }

  /// Memperbarui data berita instansi yang ada di tabel 'news_instansi' berdasarkan ID.
  Future<int> updateNewsInstansi(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('news_instansi', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus data berita instansi dari tabel 'news_instansi' berdasarkan ID.
  Future<int> deleteNewsInstansi(int id) async {
    final db = await database;
    return await db.delete('news_instansi', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Operasi CRUD untuk Tabel PEMADAM ---
  /// Memasukkan data laporan pemadam baru ke tabel 'pemadam'.
  Future<int> insertPemadam(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('pemadam', data);
  }

  /// Mengambil semua data laporan pemadam dari tabel 'pemadam', diurutkan berdasarkan waktu.
  Future<List<Map<String, dynamic>>> getAllPemadam() async {
    final db = await database;
    return await db.query('pemadam', orderBy: 'waktu DESC');
  }

  /// Memperbarui data laporan pemadam yang ada di tabel 'pemadam' berdasarkan ID.
  Future<int> updatePemadam(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('pemadam', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus data laporan pemadam dari tabel 'pemadam' berdasarkan ID.
  Future<int> deletePemadam(int id) async {
    final db = await database;
    return await db.delete('pemadam', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Operasi CRUD untuk Tabel MEDIS ---
  /// Memasukkan data laporan medis baru ke tabel 'medis'.
  Future<int> insertMedis(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('medis', data);
  }

  /// Mengambil semua data laporan medis dari tabel 'medis', diurutkan berdasarkan waktu.
  Future<List<Map<String, dynamic>>> getAllMedis() async {
    final db = await database;
    return await db.query('medis', orderBy: 'waktu DESC');
  }

  /// Memperbarui data laporan medis yang ada di tabel 'medis' berdasarkan ID.
  Future<int> updateMedis(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('medis', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus data laporan medis dari tabel 'medis' berdasarkan ID.
  Future<int> deleteMedis(int id) async {
    final db = await database;
    return await db.delete('medis', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Operasi CRUD untuk Tabel BPBD ---
  /// Memasukkan data laporan BPBD baru ke tabel 'bpbd'.
  Future<int> insertBpbd(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('bpbd', data);
  }

  /// Mengambil semua data laporan BPBD dari tabel 'bpbd', diurutkan berdasarkan waktu.
  Future<List<Map<String, dynamic>>> getAllBpbd() async {
    final db = await database;
    return await db.query('bpbd', orderBy: 'waktu DESC');
  }

  /// Memperbarui data laporan BPBD yang ada di tabel 'bpbd' berdasarkan ID.
  Future<int> updateBpbd(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('bpbd', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Menghapus data laporan BPBD dari tabel 'bpbd' berdasarkan ID.
  Future<int> deleteBpbd(int id) async {
    final db = await database;
    return await db.delete('bpbd', where: 'id = ?', whereArgs: [id]);
  }

  /// --- Fungsi untuk menghapus file database secara paksa ---
  /// Berguna untuk debugging atau reset aplikasi.
  Future<void> _deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'myapp.db');
    // Tutup database jika sedang terbuka sebelum menghapus file
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null; // Set null agar instance database baru dibuat
    }
    if (await databaseFactory.databaseExists(path)) {
      await deleteDatabase(path);
      print("Database 'myapp.db' berhasil dihapus.");
    } else {
      print("Database 'myapp.db' tidak ditemukan.");
    }
  }

  /// --- Fungsi publik untuk mereset database sepenuhnya ---
  /// Menghapus file database dan kemudian menginisialisasi ulang database,
  /// menyebabkan `onCreate` dipanggil kembali untuk membuat tabel-tabel baru.
  Future<void> resetDatabase() async {
    print("Mencoba mereset database...");
    await _deleteDatabaseFile();
    // Memastikan database akan diinisialisasi ulang setelah dihapus
    _database = await _initDatabase();
    print("Database berhasil direset dan dibuat ulang.");
  }
}
