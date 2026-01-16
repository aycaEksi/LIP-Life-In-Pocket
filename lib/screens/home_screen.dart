import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../pages/focus_page.dart';
import '../pages/calendar_page.dart';
import '../pages/todos_page.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';
import '../repositories/avatar_repository.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final ThemeManager themeManager;

  const HomeScreen({required this.themeManager, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AvatarRepository _avatarRepo = AvatarRepository();
  Map<String, dynamic>? _avatarData;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _avatarRepo.getLatestAvatarByUserId(1);
      if (avatar != null && mounted) {
        setState(() {
          _parseAvatarData(avatar.hairStyle);
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  void _parseAvatarData(String dataString) {
    try {
      final genderMatch = RegExp(r"gender: (\w+)").firstMatch(dataString);
      final skinMatch = RegExp(r"skinTone: (\w+)").firstMatch(dataString);
      final eyeMatch = RegExp(r"eye: ([\w-]+)").firstMatch(dataString);
      final eyeColorMatch =
          RegExp(r"eyeColor: (#[0-9a-fA-F]{6})").firstMatch(dataString);
      final bottomMatch =
          RegExp(r"bottom: ([\w-]+|null)").firstMatch(dataString);
      final bottomColorMatch =
          RegExp(r"bottomColor: (#[0-9a-fA-F]{6})").firstMatch(dataString);
      final topMatch = RegExp(r"top: ([\w-]+|null)").firstMatch(dataString);
      final topColorMatch =
          RegExp(r"topColor: (#[0-9a-fA-F]{6})").firstMatch(dataString);

      _avatarData = {
        'gender': genderMatch?.group(1) ?? 'male',
        'skinTone': skinMatch?.group(1) ?? 'light',
        'eye': eyeMatch?.group(1) ?? 'male-eye',
        'eyeColor': eyeColorMatch?.group(1) ?? '#8B4513',
        'bottom':
            bottomMatch?.group(1) != 'null' ? bottomMatch?.group(1) : null,
        'bottomColor': bottomColorMatch?.group(1) ?? '#000000',
        'top': topMatch?.group(1) != 'null' ? topMatch?.group(1) : null,
        'topColor': topColorMatch?.group(1) ?? '#FFFFFF',
      };
    } catch (e) {
      // Hata durumunda default değerler kullanılır
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Header - Sol Üst
            Positioned(
              top: 24,
              left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayça Ekşi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.nights_stay,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uykulu',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Header - Sağ Üst
            Positioned(
              top: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('EEEE', 'tr_TR').format(DateTime.now()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Merkez - Avatar ve Butonlar
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ekran boyutuna göre dinamik boyutlandırma
                  final availableSize =
                      math.min(size.width - 48, size.height - 200);
                  final containerSize = math.min(availableSize, 400.0);
                  final avatarSize = containerSize * 0.45; // %45
                  final buttonSize = containerSize * 0.175; // %17.5
                  final radius = containerSize * 0.35; // %35

                  return SizedBox(
                    width: containerSize,
                    height: containerSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Merkez Avatar (Büyük)
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _avatarData != null
                                ? _buildAvatarStack(avatarSize)
                                : Icon(
                                    Icons.person,
                                    size: avatarSize * 0.44,
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.3),
                                  ),
                          ),
                        ),

                        // Çevreleyen Butonlar
                        ..._buildCircularButtons(context, colorScheme,
                            containerSize, buttonSize, radius),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Theme Toggle Button
            ThemeToggleButton(themeManager: widget.themeManager),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(double size) {
    final data = _avatarData!;
    final gender = data['gender'];
    final skinTone = data['skinTone'];
    final eye = data['eye'];
    final eyeColor = _hexToColor(data['eyeColor']);
    final bottom = data['bottom'];
    final bottomColor = _hexToColor(data['bottomColor']);
    final top = data['top'];
    final topColor = _hexToColor(data['topColor']);

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        // Body (Vücut)
        Image.asset(
          'assets/images/body-$gender${skinTone == 'dark' ? '-dark' : ''}.png',
          fit: BoxFit.cover,
        ),
        // Bottom Wear
        if (bottom != null && bottom != 'null')
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              bottomColor,
              BlendMode.modulate,
            ),
            child: Image.asset(
              'assets/images/$bottom.png',
              fit: BoxFit.cover,
            ),
          ),
        // Top Wear
        if (top != null && top != 'null')
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              topColor,
              BlendMode.modulate,
            ),
            child: Image.asset(
              'assets/images/$top.png',
              fit: BoxFit.cover,
            ),
          ),
        // Eyes
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            eyeColor,
            BlendMode.modulate,
          ),
          child: Image.asset(
            'assets/images/$eye.png',
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCircularButtons(
    BuildContext context,
    ColorScheme colorScheme,
    double containerSize,
    double buttonSize,
    double radius,
  ) {
    final buttons = [
      _CircularButton(
        icon: Icons.person_outline,
        label: 'Profil',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProfileScreen(themeManager: widget.themeManager),
            ),
          );
        },
      ),
      _CircularButton(
        icon: Icons.help_outline,
        label: 'Focus',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FocusPage()),
          );
        },
      ),
      _CircularButton(
        icon: Icons.calendar_month,
        label: 'Takvim',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarPage()),
          );
        },
      ),
      _CircularButton(
        icon: Icons.timer_outlined,
        label: 'Görevler',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodosPage()),
          );
        },
      ),
      _CircularButton(
        icon: Icons.settings,
        label: 'Ayarlar',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SettingsScreen(themeManager: widget.themeManager),
            ),
          );
        },
      ),
    ];

    return List.generate(buttons.length, (index) {
      final angle = (index * 2 * math.pi / buttons.length) - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      return Positioned(
        left: (containerSize / 2) + x - (buttonSize / 2),
        top: (containerSize / 2) + y - (buttonSize / 2),
        child: _buildButton(
          context,
          buttons[index].icon,
          buttons[index].onTap,
          colorScheme,
          buttonSize,
        ),
      );
    });
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
    ColorScheme colorScheme,
    double size,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.45, // Icon boyutu buton boyutunun %45'i
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _CircularButton {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _CircularButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
