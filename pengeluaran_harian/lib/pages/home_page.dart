import 'package:flutter/material.dart';
import '../data/pengeluaran_repo.dart';
import 'pengeluaran_page.dart';
import 'uji_coba_page.dart';

class HomePage extends StatefulWidget {
  final PengeluaranRepo sqlite;
  final PengeluaranRepo hive;
  const HomePage({super.key, required this.sqlite, required this.hive});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  static const _judul = ['Pengeluaran (SQLite)', 'Pengeluaran (Hive)', 'Uji Coba dan Ringkasan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_tab])),
      body: IndexedStack(
        index: _tab,
        children: [
          PengeluaranPage(repo: widget.sqlite),
          PengeluaranPage(repo: widget.hive),
          const UjiCobaPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storage), label: 'SQLite'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Hive'),
          NavigationDestination(icon: Icon(Icons.speed), label: 'Uji Coba'),
        ],
      ),
    );
  }
}
