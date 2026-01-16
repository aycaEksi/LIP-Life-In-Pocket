import 'package:flutter/material.dart';
import 'avatar_editor_screen.dart';
import 'mood_selector_screen.dart';
import 'settings_screen.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeManager themeManager;
  
  const ProfileScreen({required this.themeManager, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Avatar Düzenleme Butonu
                    _buildProfileButton(
                      context: context,
                      icon: Icons.person_outline,
                      title: 'Avatar Düzenleme',
                      subtitle: 'Karakterini özelleştir',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvatarEditorScreen(themeManager: widget.themeManager),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ruh Hali Seçme Butonu
                    _buildProfileButton(
                      context: context,
                      icon: Icons.emoji_emotions_outlined,
                      title: 'Ruh Hali',
                      subtitle: 'Bugünkü ruh halini seç',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MoodSelectorScreen(themeManager: widget.themeManager),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ayarlar Butonu
                    _buildProfileButton(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: 'Ayarlar',
                      subtitle: 'Uygulama ayarlarını düzenle',
                      color: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(themeManager: widget.themeManager),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Theme Toggle Button
          ThemeToggleButton(themeManager: widget.themeManager),
        ],
      ),
    );
  }

  Widget _buildProfileButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 28 : 32,
                  color: color,
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: isSmallScreen ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
