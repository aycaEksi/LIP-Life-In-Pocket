import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeManager themeManager;
  
  const SettingsScreen({required this.themeManager, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _logout() async {
    // Çıkış yapma onayı
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // Oturum bilgisini temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      
      // Login ekranına dön
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(themeManager: widget.themeManager),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Stack(
        children: [
          ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.person, color: colorScheme.primary),
              title: const Text('Profil Ayarları'),
              subtitle: const Text('Kullanıcı bilgilerinizi düzenleyin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Profil ayarları sayfası
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: colorScheme.primary),
              title: const Text('Bildirimler'),
              subtitle: const Text('Bildirim ayarlarını yönetin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Bildirim ayarları
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.palette, color: colorScheme.primary),
              title: const Text('Tema'),
              subtitle: const Text('Uygulama görünümünü değiştirin'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Tema ayarları
              },
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: colorScheme.errorContainer,
            child: ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Çıkış Yap',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: _logout,
            ),
          ),
        ],
      ),
          
          // Theme Toggle Button
          ThemeToggleButton(themeManager: widget.themeManager),
        ],
      ),
    );
  }
}
