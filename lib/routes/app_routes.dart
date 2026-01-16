import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../theme/theme_manager.dart';

class AppRoutes {
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String login = '/login';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings, ThemeManager themeManager) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen(themeManager: themeManager));
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen(themeManager: themeManager));
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => SettingsScreen(themeManager: themeManager));
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen(themeManager: themeManager));
      default:
        return null;
    }
  }
}
