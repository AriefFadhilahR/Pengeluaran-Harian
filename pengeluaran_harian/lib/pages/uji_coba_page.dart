import 'package:flutter/material.dart';
import '../data/benchmark.dart';

class UjiCobaPage extends StatefulWidget {
  const UjiCobaPage({super.key});

  @override
  State<UjiCobaPage> createState() => _UjiCobaPageState();
}

class _UjiCobaPageState extends State<UjiCobaPage> {
  static const _jumlahData = 100;
  bool _jalan = false;
  List<HasilBenchmark>? _hasil;

  Future<void> _uji() async {
    setState(() => _jalan = true);
    final h = await jalankanBenchmark(_jumlahData);
    if (!mounted) return;
    setState(() {
      _hasil = h;
      _jalan = false;
    });
  }

  Widget _baris(String a, String b, String c, {bool tebal = false}) {
    final gaya = TextStyle(fontWeight: tebal ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: Text(a, style: gaya.copyWith(fontWeight: FontWeight.bold))),
        Expanded(flex: 4, child: Text(b, style: gaya)),
        Expanded(flex: 4, child: Text(c, style: gaya)),
      ]),
    );
  }

  Widget _kartu(String judul, List<Widget> isi) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(judul, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...isi,
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final h = _hasil;
    return ListView(padding: const EdgeInsets.all(12), children: [
      _kartu('Perbandingan SQLite dan Hive', [
        _baris('Aspek', 'SQLite', 'Hive', tebal: true),
        const Divider(height: 1),
        _baris('Jenis', 'Relasional (SQL)', 'NoSQL key-value'),
        _baris('Skema', 'Wajib (tabel dan kolom)', 'Fleksibel, tanpa skema'),
        _baris('Query', 'Kuat (WHERE, ORDER BY, JOIN)', 'Terbatas'),
        _baris('Kemudahan', 'Perlu menulis SQL', 'API sederhana'),
        _baris('Cocok untuk', 'Data terstruktur dan relasi', 'Data sederhana, cache'),
      ]),
      _kartu('Uji kecepatan CRUD ($_jumlahData data)', [
        const Text('Menjalankan tambah, baca, ubah, dan hapus sebanyak $_jumlahData data di database terpisah '
            '(data aplikasi tidak terpengaruh).'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _jalan ? null : _uji,
          icon: _jalan
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.play_arrow),
          label: Text(_jalan ? 'Menjalankan...' : 'Jalankan uji'),
        ),
        if (h != null) ...[
          const SizedBox(height: 12),
          _baris('Operasi', 'SQLite (ms)', 'Hive (ms)', tebal: true),
          const Divider(height: 1),
          _baris('Tambah', '${h[0].tambahMs}', '${h[1].tambahMs}'),
          _baris('Baca', '${h[0].bacaMs}', '${h[1].bacaMs}'),
          _baris('Ubah', '${h[0].ubahMs}', '${h[1].ubahMs}'),
          _baris('Hapus', '${h[0].hapusMs}', '${h[1].hapusMs}'),
          const SizedBox(height: 8),
          const Text('Hasil bisa berbeda tiap perangkat. Makin kecil makin cepat.',
              style: TextStyle(fontSize: 12)),
        ],
      ]),
      _kartu('Kesimpulan', [
        const Text('SQLite cocok untuk data terstruktur yang butuh query dan relasi antar tabel. '
            'Hive lebih praktis dan ringan untuk data sederhana karena tanpa skema dan tanpa SQL. '
            'Keduanya berhasil menjalankan operasi CRUD pada aplikasi pengeluaran ini.'),
      ]),
    ]);
  }
}
