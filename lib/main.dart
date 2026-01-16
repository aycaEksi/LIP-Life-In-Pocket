import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db/app_db.dart';
import 'services/auth_service.dart';
import 'pages/hub_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ enable SQLite on Windows
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await AppDb.instance.init();
  await AuthService.instance.ensureTestUserOnFirstLaunch();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HubPage(),
    );
  }
}
