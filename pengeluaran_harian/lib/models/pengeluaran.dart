import 'package:flutter/material.dart';

const kategoriList = ['Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Lainnya'];

Color warnaKategori(String k) {
  switch (k) {
    case 'Makanan':
      return Colors.orange;
    case 'Transportasi':
      return Colors.blue;
    case 'Belanja':
      return Colors.pink;
    case 'Hiburan':
      return Colors.purple;
    default:
      return Colors.teal;
  }
}

IconData ikonKategori(String k) {
  switch (k) {
    case 'Makanan':
      return Icons.restaurant;
    case 'Transportasi':
      return Icons.directions_bus;
    case 'Belanja':
      return Icons.shopping_bag;
    case 'Hiburan':
      return Icons.movie;
    default:
      return Icons.more_horiz;
  }
}

/// 1500000 -> "Rp 1.500.000"
String rupiah(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp ${n < 0 ? '-' : ''}$b';
}

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

class Pengeluaran {
  final int? id;
  final String judul;
  final int jumlah;
  final String kategori;
  final DateTime tanggal;

  Pengeluaran({
    this.id,
    required this.judul,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Pengeluaran copyWith({String? judul, int? jumlah, String? kategori, DateTime? tanggal}) =>
      Pengeluaran(
        id: id,
        judul: judul ?? this.judul,
        jumlah: jumlah ?? this.jumlah,
        kategori: kategori ?? this.kategori,
        tanggal: tanggal ?? this.tanggal,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'judul': judul,
        'jumlah': jumlah,
        'kategori': kategori,
        'tanggal': tanggal.toIso8601String(),
      };

  factory Pengeluaran.fromMap(Map<String, dynamic> m) => Pengeluaran(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        jumlah: (m['jumlah'] as num).toInt(),
        kategori: m['kategori'] as String,
        tanggal: DateTime.parse(m['tanggal'] as String),
      );
}

/// Data contoh agar aplikasi tidak kosong saat pertama dibuka
List<Pengeluaran> contohData() {
  final n = DateTime.now();
  DateTime h(int hari) => DateTime(n.year, n.month, n.day).subtract(Duration(days: hari));
  return [
    Pengeluaran(judul: 'Makan siang warteg', jumlah: 18000, kategori: 'Makanan', tanggal: h(0)),
    Pengeluaran(judul: 'Ongkos angkot', jumlah: 12000, kategori: 'Transportasi', tanggal: h(0)),
    Pengeluaran(judul: 'Beli buku catatan', jumlah: 35000, kategori: 'Belanja', tanggal: h(1)),
    Pengeluaran(judul: 'Nonton bioskop', jumlah: 50000, kategori: 'Hiburan', tanggal: h(2)),
    Pengeluaran(judul: 'Kopi dan roti', jumlah: 27000, kategori: 'Makanan', tanggal: h(3)),
    Pengeluaran(judul: 'Isi pulsa', jumlah: 25000, kategori: 'Lainnya', tanggal: h(4)),
    Pengeluaran(judul: 'Bensin motor', jumlah: 30000, kategori: 'Transportasi', tanggal: h(5)),
  ];
}
