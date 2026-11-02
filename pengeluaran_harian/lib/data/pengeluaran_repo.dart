import '../models/pengeluaran.dart';

/// Kontrak CRUD yang sama dipakai oleh SQLite dan Hive
abstract class PengeluaranRepo {
  String get nama;
  Future<List<Pengeluaran>> semua(); // Read
  Future<void> tambah(Pengeluaran p); // Create
  Future<void> ubah(Pengeluaran p); // Update
  Future<void> hapus(int id); // Delete

  /// Menutup dan menghapus penyimpanan (dipakai oleh uji kecepatan)
  Future<void> hapusPermanen();
}
