import '../models/pengeluaran.dart';
import 'hive_repo.dart';
import 'pengeluaran_repo.dart';
import 'sqlite_repo.dart';

class HasilBenchmark {
  final String nama;
  final int tambahMs;
  final int bacaMs;
  final int ubahMs;
  final int hapusMs;
  HasilBenchmark(this.nama, this.tambahMs, this.bacaMs, this.ubahMs, this.hapusMs);
}

Future<HasilBenchmark> _ukur(PengeluaranRepo repo, int n) async {
  final sw = Stopwatch()..start();

  for (var i = 0; i < n; i++) {
    await repo.tambah(Pengeluaran(
      judul: 'Uji $i',
      jumlah: 1000 + i,
      kategori: 'Lainnya',
      tanggal: DateTime.now(),
    ));
  }
  final tambah = sw.elapsedMilliseconds;
  sw.reset();

  final data = await repo.semua();
  final baca = sw.elapsedMilliseconds;
  sw.reset();

  for (final p in data) {
    await repo.ubah(p.copyWith(jumlah: p.jumlah + 1));
  }
  final ubah = sw.elapsedMilliseconds;
  sw.reset();

  for (final p in data) {
    await repo.hapus(p.id!);
  }
  final hapus = sw.elapsedMilliseconds;

  return HasilBenchmark(repo.nama, tambah, baca, ubah, hapus);
}

/// Menjalankan uji CRUD sebanyak [n] data pada SQLite dan Hive
/// (memakai database terpisah, data aplikasi tidak terganggu).
Future<List<HasilBenchmark>> jalankanBenchmark(int n) async {
  final sqlite = SqliteRepo(dbName: 'benchmark.db', seed: false);
  final hive = await HiveRepo.buka(boxName: 'benchmark_box', seed: false);
  try {
    final a = await _ukur(sqlite, n);
    final b = await _ukur(hive, n);
    return [a, b];
  } finally {
    await sqlite.hapusPermanen();
    await hive.hapusPermanen();
  }
}
