import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pengeluaran.dart';
import 'pengeluaran_repo.dart';

/// Penyimpanan utama: SQLite lewat package sqflite
class SqliteRepo implements PengeluaranRepo {
  final String dbName;
  final bool seed;
  SqliteRepo({this.dbName = 'pengeluaran.db', this.seed = true});

  Database? _db;

  @override
  String get nama => 'SQLite';

  Future<Database> get _database async => _db ??= await _init();

  // Membuat database dan skema tabel
  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pengeluaran(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            jumlah INTEGER NOT NULL,
            kategori TEXT NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
        if (seed) {
          for (final p in contohData()) {
            await db.insert('pengeluaran', p.toMap());
          }
        }
      },
    );
  }

  // CREATE
  @override
  Future<void> tambah(Pengeluaran p) async {
    final db = await _database;
    await db.insert('pengeluaran', p.toMap());
  }

  // READ
  @override
  Future<List<Pengeluaran>> semua() async {
    final db = await _database;
    final rows = await db.query('pengeluaran', orderBy: 'tanggal DESC, id DESC');
    return rows.map(Pengeluaran.fromMap).toList();
  }

  // UPDATE
  @override
  Future<void> ubah(Pengeluaran p) async {
    final db = await _database;
    await db.update('pengeluaran', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  // DELETE
  @override
  Future<void> hapus(int id) async {
    final db = await _database;
    await db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> hapusPermanen() async {
    final db = await _database;
    await db.close();
    _db = null;
    await deleteDatabase(join(await getDatabasesPath(), dbName));
  }
}
