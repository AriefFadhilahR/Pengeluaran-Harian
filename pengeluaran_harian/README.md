# Pengeluaran Harian (Flutter: SQLite dan Hive)

Aplikasi pencatat pengeluaran harian untuk tugas penyimpanan lokal di Flutter
(Praktikum Mobile Programming).

- **SQLite (sqflite):** database dan skema tabel `pengeluaran`, CRUD lengkap
- **Hive:** local storage alternatif dengan CRUD yang sama
- **Tab Uji Coba:** perbandingan dan uji kecepatan CRUD SQLite vs Hive
- Dokumentasi: lihat file PDF laporan di folder ini

## Cara menjalankan
```
flutter pub get
flutter run
```
Jalankan di emulator atau HP **Android**. Package sqflite tidak mendukung Chrome (web)
dan desktop (Windows/Linux/macOS) secara bawaan, jadi folder platform tersebut tidak disertakan.

## Struktur kode
```
lib/
  main.dart                     inisialisasi Hive dan aplikasi
  models/pengeluaran.dart       model data, kategori, format rupiah dan tanggal
  data/pengeluaran_repo.dart    antarmuka CRUD
  data/sqlite_repo.dart         implementasi SQLite (sqflite)
  data/hive_repo.dart           implementasi Hive
  data/benchmark.dart           uji kecepatan CRUD
  pages/home_page.dart          navigasi 3 tab
  pages/pengeluaran_page.dart   tampilan daftar dan form CRUD
  pages/uji_coba_page.dart      perbandingan dan uji kecepatan
```
