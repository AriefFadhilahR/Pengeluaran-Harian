import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/hive_repo.dart';
import 'data/sqlite_repo.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final sqlite = SqliteRepo();
  final hive = await HiveRepo.buka();
  runApp(MyApp(sqlite: sqlite, hive: hive));
}

class MyApp extends StatelessWidget {
  final SqliteRepo sqlite;
  final HiveRepo hive;
  const MyApp({super.key, required this.sqlite, required this.hive});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengeluaran Harian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: HomePage(sqlite: sqlite, hive: hive),
    );
  }
}
