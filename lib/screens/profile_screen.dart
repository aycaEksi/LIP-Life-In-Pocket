import 'dart:math' as math;
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
  int? _hovered;

  // --- colors close to reference ---
  static const _bgTopLight = Color(0xFFF6EEFF);
  static const _bgBottomLight = Color(0xFFEDE6FF);

  static const _bgTopDark = Color(0xFF140824);
  static const _bgBottomDark = Color(0xFF0B0516);

  static const _cardStroke = Color(0xFFE8DFFF);
  static const _cardFillA = Color(0xFFECE6FF);
  static const _cardFillB = Color(0xFFF3E8FF);

  static const _purple = Color(0xFF7B2CFF);
  static const _purple2 = Color(0xFFA46BFF);
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                children: [
                  _topBar(context, isDark),
                  const SizedBox(height: 26),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: LayoutBuilder(
                          builder: (context, c) {
                            final w = c.maxWidth;
                            final isNarrow = w < 900;

                            final cards = <_ProfileCardData>[
                              _ProfileCardData(
                                title: "Avatar",
                                subtitle: "Avatarınızı kişiselleştirin",
                                icon: Icons.person_outline,
                                tint: const Color(0xFF7B2CFF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AvatarEditorScreen(
                                        themeManager: widget.themeManager,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _ProfileCardData(
                                title: "Ayarlar",
                                subtitle: "Çıkış yapın veya profili görüntüleyin",
                                icon: Icons.settings_outlined,
                                tint: const Color(0xFF4B55FF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SettingsScreen(
                                        themeManager: widget.themeManager,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _ProfileCardData(
                                title: "Ruh Hali",
                                subtitle:
                                    "Gününüzü puanlayın ve AI tavsiyenizi\nalın!",
                                icon: Icons.emoji_emotions_outlined,
                                tint: const Color(0xFFB000FF),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MoodSelectorScreen(
                                        themeManager: widget.themeManager,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ];

                            if (isNarrow) {
                              return Wrap(
                                spacing: 18,
                                runSpacing: 18,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                  cards.length,
                                  (i) => _profileCard(
                                    data: cards[i],
                                    index: i,
                                    isDark: isDark,
                                    size: math.min(330, w),
                                  ),
                                ),
                              );
                            }

                            final size = math.min(340.0, w / 3.2);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _profileCard(
                                  data: cards[0],
                                  index: 0,
                                  isDark: isDark,
                                  size: size,
                                ),
                                const SizedBox(width: 22),
                                _profileCard(
                                  data: cards[1],
                                  index: 1,
                                  isDark: isDark,
                                  size: size,
                                ),
                                const SizedBox(width: 22),
                                _profileCard(
                                  data: cards[2],
                                  index: 2,
                                  isDark: isDark,
                                  size: size,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          ThemeToggleButton(themeManager: widget.themeManager),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context, bool isDark) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: isDark ? Colors.white70 : _purple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "GERI DÖN",
                      style: TextStyle(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : _purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Profil",
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w700,
                fontFamily: "serif",
                color: isDark ? Colors.white : const Color(0xFF2B2338),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required _ProfileCardData data,
    required int index,
    required bool isDark,
    required double size,
  }) {
    final hovered = _hovered == index;

    final baseFill = isDark
        ? const LinearGradient(
            colors: [Color(0xFF221038), Color(0xFF1A0C2E)],
          )
        : const LinearGradient(colors: [_cardFillA, _cardFillB]);

    final cardShadow = hovered
        ? [
            BoxShadow(
              color: (isDark ? Colors.black : _purple).withOpacity(0.22),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.16),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = index),
      onExit: (_) => setState(() => _hovered = null),
      child: GestureDetector(
        onTap: data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: size,
          height: size,
          transformAlignment: Alignment.center,
          // grow + "lean right"
          transform: Matrix4.identity()
            ..translate(0.0, hovered ? -6.0 : 0.0)
            ..scale(hovered ? 1.06 : 1.0)
            ..rotateZ(hovered ? 0.04 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: baseFill,
            border: Border.all(
              color: isDark ? Colors.white10 : _cardStroke,
              width: 1.2,
            ),
            boxShadow: cardShadow,
          ),
          child: Stack(
            children: [
              // little sparkle
              Positioned(
                right: 16,
                top: 16,
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: isDark ? Colors.white24 : _purple.withOpacity(0.35),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: hovered ? 108 : 98,
                      height: hovered ? 108 : 98,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        data.icon,
                        size: hovered ? 54 : 50,
                        color: data.tint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: data.tint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      child: hovered
                          ? Text(
                              data.subtitle,
                              key: ValueKey("sub_$index"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: data.tint.withOpacity(0.9),
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey("sub_empty"),
                              height: 0,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  _ProfileCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });
}
