import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'db/app_db.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe locale'i başlat
  await initializeDateFormatting('tr_TR', null);

  // Windows, Linux, macOS için sqflite_ffi başlatma
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Veritabanı ve auth servisini başlat
  await AppDb.instance.init();
  await AuthService.instance.ensureTestUserOnFirstLaunch();

  // Bildirim servisini başlat (sadece mobil platformlarda)
  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationService.instance.init();
    
    // 2 saatte bir mood insight bildirimleri başlat
    await NotificationService.instance.scheduleMoodInsights();
    
    // Su içme hatırlatıcıları başlat (09:00, 12:00, 15:00, 18:00, 21:00)
    await NotificationService.instance.scheduleWaterReminders();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiP - Life in Pocket',
      debugShowCheckedModeBanner: false,

      // Tema yapılandırması - ThemeManager ile yönetiliyor
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeManager.themeMode,

      home: AuthChecker(themeManager: _themeManager),
    );
  }
}

class AuthChecker extends StatefulWidget {
  final ThemeManager themeManager;

  const AuthChecker({required this.themeManager, super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Token varsa profil endpoint'ine istek at
    final token = await ApiService.instance.getToken();
    
    if (token != null) {
      // Token varsa profil bilgilerini kontrol et
      try {
        final isAuthenticated = await ApiService.instance.isAuthenticated();
        setState(() {
          _isLoggedIn = isAuthenticated;
          _isLoading = false;
        });
      } catch (e) {
        // Token geçersiz, logout yap
        await ApiService.instance.logout();
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn
        ? HomeScreen(themeManager: widget.themeManager)
        : LoginScreen(themeManager: widget.themeManager);
  }
}
