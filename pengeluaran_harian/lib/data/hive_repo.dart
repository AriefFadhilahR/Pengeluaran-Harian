import 'package:hive_flutter/hive_flutter.dart';
import '../models/pengeluaran.dart';
import 'pengeluaran_repo.dart';

/// Local storage alternatif: Hive (NoSQL key-value)
class HiveRepo implements PengeluaranRepo {
  final Box _box;
  HiveRepo._(this._box);

  static Future<HiveRepo> buka({String boxName = 'pengeluaran_box', bool seed = true}) async {
    final baru = !await Hive.boxExists(boxName);
    final box = await Hive.openBox(boxName);
    if (baru && seed) {
      for (final p in contohData()) {
        await box.add(p.toMap());
      }
    }
    return HiveRepo._(box);
  }

  @override
  String get nama => 'Hive';

  // CREATE (key auto-increment)
  @override
  Future<void> tambah(Pengeluaran p) async {
    await _box.add(p.toMap());
  }

  // READ
  @override
  Future<List<Pengeluaran>> semua() async {
    return _box.keys.map((k) {
      final m = Map<String, dynamic>.from(_box.get(k) as Map);
      return Pengeluaran.fromMap({...m, 'id': k});
    }).toList();
  }

  // UPDATE
  @override
  Future<void> ubah(Pengeluaran p) async {
    await _box.put(p.id, p.toMap());
  }

  // DELETE
  @override
  Future<void> hapus(int id) async {
    await _box.delete(id);
  }

  @override
  Future<void> hapusPermanen() async {
    await _box.deleteFromDisk();
  }
}
