import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zona_beladiri.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Membuat tabel untuk mencatat performa fisik murid
    await db.execute('''
      CREATE TABLE murid_fisik (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        jumlah_push_up INTEGER NOT NULL,
        catatan_hapkido TEXT,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  // Fungsi untuk memasukkan data latihan baru
  Future<int> tambahDataFisik(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('murid_fisik', row);
  }

  // Fungsi untuk menarik semua list data murid
  Future<List<Map<String, dynamic>>> ambilSemuaData() async {
    final db = await instance.database;
    return await db.query('murid_fisik', orderBy: 'tanggal DESC');
  }
}
