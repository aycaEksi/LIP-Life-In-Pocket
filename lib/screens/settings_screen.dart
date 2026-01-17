import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeManager themeManager;

  const SettingsScreen({required this.themeManager, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- colors close to reference ---
  static const _bgTopLight = Color(0xFFF6EEFF);
  static const _bgBottomLight = Color(0xFFF0E9FF);
  static const _bgTopDark = Color(0xFF140824);
  static const _bgBottomDark = Color(0xFF0B0516);

  static const _cardStroke = Color(0xFFEDE5FF);
  static const _muted = Color(0xFF8F7BB7);

  static const _purple = Color(0xFF7B2CFF);

  // log out gradient (red -> magenta)
  static const _logoutA = Color(0xFFEF2B2B);
  static const _logoutB = Color(0xFFD8009A);
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
      // API servisi ile logout yap
      await ApiService.instance.logout();

      // Login ekranına dön
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(themeManager: widget.themeManager),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.25),
                  radius: 1.25,
                  colors: isDark
                      ? const [_bgTopDark, _bgBottomDark]
                      : const [_bgTopLight, _bgBottomLight],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(context, isDark),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            _settingsCard(
                              isDark: isDark,
                              icon: Icons.person_outline,
                              title: 'Profil Ayarları',
                              subtitle: 'Profilinizi Yönetin',
                              onTap: () {
                                // Profil ayarları
                              },
                            ),
                            const SizedBox(height: 14),
                            _settingsCard(
                              isDark: isDark,
                              icon: Icons.notifications_none_rounded,
                              title: 'Bildirimler',
                              subtitle: 'Bildirimleri Yönetin',
                              onTap: () {
                                // Bildirim ayarları
                              },
                            ),
                            const SizedBox(height: 14),
                            _settingsCard(
                              isDark: isDark,
                              icon: Icons.palette_outlined,
                              title: 'Tema',
                              subtitle: 'Temayı Yönetin',
                              onTap: () {
                                // Tema ayarları
                              },
                            ),
                            const SizedBox(height: 28),
                            _logoutButton(isDark: isDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle Button
          ThemeToggleButton(themeManager: widget.themeManager),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white70 : _purple,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
          Text(
            "Ayarlar",
            style: TextStyle(
              color: isDark ? Colors.white : _purple,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40), // balance center title
        ],
      ),
    );
  }

  Widget _settingsCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final fill = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.78);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white12 : _cardStroke,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.28 : 0.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFF2EAFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _purple, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF2B2338),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : _muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white54 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton({required bool isDark}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _logout,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [_logoutA, _logoutB]),
          boxShadow: [
            BoxShadow(
              color: _logoutB.withOpacity(0.25),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Çıkış Yap",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
