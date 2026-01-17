import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'profile_screen.dart';
import '../pages/focus_page.dart';
import '../pages/calendar_page.dart';
import '../pages/todos_page.dart';

import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final ThemeManager themeManager;

  const HomeScreen({required this.themeManager, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _avatarData;
  String _moodStatus = 'Yüklüyor...';
  bool _isMoodLoading = true;
  String _userName = 'Kullanıcı';

  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    print('🚀 HomeScreen initState başladı');
    _loadUserName();
    _loadAvatar();
    _loadMoodStatus();
    print('🚀 HomeScreen initState tamamlandı');

    // update time on screen (every 10s)
    _clockTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final user = await ApiService.instance.getUser();
      if (user != null && user['name'] != null && mounted) {
        setState(() {
          _userName = user['name'];
        });
      }
    } catch (e) {
      debugPrint('Kullanıcı adı yükleme hatası: $e');
    }
  }

  Future<void> _loadAvatar() async {
    try {
      print('🎭 Avatar yükleniyor...');
      final response = await ApiService.instance.getAvatar();
      
      print('🎭 Avatar Response Status: ${response.statusCode}');
      print('🎭 Avatar Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🎭 Avatar Data: $data');
        if (mounted) {
          setState(() {
            _parseAvatarFromApi(data);
          });
          print('🎭 Avatar parsed: $_avatarData');
        }
      } else {
        // API'den veri gelmezse default avatar
        print('⚠️ Avatar API hatası, default avatar ayarlanıyor');
        if (mounted) {
          setState(() {
            _avatarData = {
              'gender': 'female',
              'skinTone': 'light',
              'eye': 'female-eye',
              'eyeColor': '#8B4513',
              'hair': null,
              'hairColor': '#3D2817',
              'bottom': null,
              'bottomColor': '#0000FF',
              'top': null,
              'topColor': '#FF0000',
            };
          });
        }
      }
    } catch (e) {
      print('❌ Avatar yükleme hatası: $e');
      // Hata durumunda default avatar göster
      if (mounted) {
        setState(() {
          _avatarData = {
            'gender': 'female',
            'skinTone': 'light',
            'eye': 'female-eye',
            'eyeColor': '#8B4513',
            'hair': null,
            'hairColor': '#3D2817',
            'bottom': null,
            'bottomColor': '#0000FF',
            'top': null,
            'topColor': '#FF0000',
          };
        });
      }
    }
  }

  Future<void> _loadMoodStatus() async {
    print('🔍 _loadMoodStatus fonksiyonu BAŞLADI');
    try {
      print('🔍 Mood durumu yükleniyor...');
      // Backend'den hazır durum bilgisini al
      print('📞 API çağrısı yapılıyor: getLatestDurum()');
      final response = await ApiService.instance.getLatestDurum();
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Durum Response: $data');
        print('🔑 Durum field: ${data['durum']}');
        print('🔑 Data keys: ${data.keys.toList()}');
        
        if (mounted) {
          final durumText = data['durum'] ?? 'Belirsiz';
          print('📝 Setting moodStatus to: $durumText');
          setState(() {
            _moodStatus = durumText;
            _isMoodLoading = false;
          });
          print('✅ setState completed, _moodStatus is now: $_moodStatus');
        }
      } else {
        print('❌ Durum API hatası: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _moodStatus = 'Henüz kayıt yok';
            _isMoodLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('❌ HATA YAKALANDI: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _moodStatus = 'Bilinmiyor';
          _isMoodLoading = false;
        });
      }
    }
    print('🏁 _loadMoodStatus fonksiyonu BİTTİ');
  }

  void _parseAvatarFromApi(Map<String, dynamic> data) {
    try {
      final gender = data['gender'] ?? 'male';
      final skinTone = data['skin_tone'] ?? 'light';
      
      _avatarData = {
        'gender': gender,
        'skinTone': skinTone,
        'eye': gender == 'male' ? 'male-eye' : 'female-eye',
        'eyeColor': data['eye_color'] ?? '#8B4513',
        'hair': data['hair_style'],
        'hairColor': data['hair_color'] ?? '#3D2817',
        'bottom': data['bottom_clothing'],
        'bottomColor': data['bottom_clothing_color'] ?? '#0000FF',
        'top': data['top_clothing'],
        'topColor': data['top_clothing_color'] ?? '#FF0000',
      };
    } catch (e) {
      debugPrint('Avatar parse hatası: $e');
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final dayTr = DateFormat('EEEE', 'tr_TR').format(now).toUpperCase();
    final timeStr = DateFormat('HH:mm').format(now);

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND (light/dark with gradient + blobs)
          Positioned.fill(child: _background(isDark: isDark)),

          SafeArea(
            child: Stack(
              children: [
                // TOP LEFT
                Positioned(
                  top: 22,
                  left: 22,
                  child: _topLeftHeader(isDark: isDark),
                ),

                // TOP RIGHT (DAY + TIME)
                Positioned(
                  top: 22,
                  right: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dayTr,
                        style: TextStyle(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withOpacity(0.75)
                              : const Color(0xFF6C5A8D).withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                          color:
                              isDark ? Colors.white : const Color(0xFF14111C),
                        ),
                      ),
                    ],
                  ),
                ),

                // CENTER (avatar + 4 buttons)
                Center(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final size = MediaQuery.of(context).size;

                      final available =
                          math.min(size.width - 48, size.height - 200);
                      final containerSize = math.min(available, 520.0);

                      final avatarSize = containerSize * 0.44;
                      final ringSize = avatarSize * 1.22;

                      final btnSize = containerSize * 0.16; // rounded-square
                      final gap = containerSize * 0.34;

                      return SizedBox(
                        width: containerSize,
                        height: containerSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // soft ring behind avatar
                            Container(
                              width: ringSize,
                              height: ringSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.10)
                                      : Colors.white.withOpacity(0.55),
                                  width: 10,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? const Color(0xFF7B2CFF)
                                            .withOpacity(0.25)
                                        : const Color(0xFF7B2CFF)
                                            .withOpacity(0.12),
                                    blurRadius: 40,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            ),

                            // AVATAR CIRCLE
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.white.withOpacity(0.70),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.35 : 0.12,
                                    ),
                                    blurRadius: 26,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _avatarData != null
                                    ? Transform.translate(
                                        offset: Offset(0, avatarSize * 0.50),
                                        child: Transform.scale(
                                          scale: 2.2,
                                          child: _buildAvatarStack(avatarSize),
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: avatarSize * 0.44,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.35)
                                            : const Color(0xFF7B2CFF)
                                                .withOpacity(0.35),
                                      ),
                              ),
                            ),

                            // 4 BUTTONS around
                            Positioned(
                              top: (containerSize / 2) - gap - (btnSize / 2),
                              child: _glassSquareButton(
                                size: btnSize,
                                icon: Icons.person_outline,
                                hoverLabel: 'Profil',
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        themeManager: widget.themeManager,
                                      ),
                                    ),
                                  ).then((_) {
                                    // Profile screen'den döndüğünde avatar'ı yeniden yükle
                                    _loadAvatar();
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              left: (containerSize / 2) - gap - (btnSize / 2),
                              child: _glassSquareButton(
                                size: btnSize,
                                icon: Icons.access_time_rounded,
                                hoverLabel: 'Odak Modu',
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FocusPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: (containerSize / 2) - gap - (btnSize / 2),
                              child: _glassSquareButton(
                                size: btnSize,
                                icon: Icons.calendar_month,
                                hoverLabel: 'Günlük Girişi',
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CalendarPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: (containerSize / 2) - gap - (btnSize / 2),
                              child: _glassSquareButton(
                                size: btnSize,
                                icon: Icons.check_box_outlined,
                                hoverLabel: 'Yapılacaklar',
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TodosPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // THEME TOGGLE (bottom-right)
                ThemeToggleButton(themeManager: widget.themeManager),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topLeftHeader({required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _userName,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF14111C),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.favorite,
              size: 18,
              color: isDark ? const Color(0xFFB27BFF) : const Color(0xFF7B2CFF),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              _isMoodLoading ? Icons.hourglass_empty : Icons.nights_stay,
              size: 16,
              color: isDark
                  ? Colors.white.withOpacity(0.55)
                  : const Color(0xFF6C5A8D).withOpacity(0.75),
            ),
            const SizedBox(width: 8),
            Text(
              'ŞU AN: ${_moodStatus.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : const Color(0xFF6C5A8D).withOpacity(0.75),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _background({required bool isDark}) {
    if (!isDark) {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.7),
            radius: 1.6,
            colors: [
              Color(0xFFF5EDFF),
              Color(0xFFF3EFFF),
              Color(0xFFF6F2FF),
            ],
          ),
        ),
        child: Stack(
          children: [
            _softBlob(
              alignment: const Alignment(-0.95, -0.75),
              color: const Color(0xFFB07CFF).withOpacity(0.18),
              size: 420,
            ),
            _softBlob(
              alignment: const Alignment(0.85, -0.10),
              color: const Color(0xFF7B2CFF).withOpacity(0.10),
              size: 520,
            ),
            _softBlob(
              alignment: const Alignment(0.35, 0.85),
              color: const Color(0xFF2E6BFF).withOpacity(0.06),
              size: 520,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.55),
          radius: 1.6,
          colors: [
            Color(0xFF140B26),
            Color(0xFF10071F),
            Color(0xFF0C0519),
          ],
        ),
      ),
      child: Stack(
        children: [
          _softBlob(
            alignment: const Alignment(-0.95, -0.65),
            color: const Color(0xFF7B2CFF).withOpacity(0.22),
            size: 520,
          ),
          _softBlob(
            alignment: const Alignment(0.80, 0.05),
            color: const Color(0xFFB27BFF).withOpacity(0.12),
            size: 560,
          ),
          _softBlob(
            alignment: const Alignment(0.30, 0.92),
            color: const Color(0xFF2E6BFF).withOpacity(0.08),
            size: 560,
          ),
        ],
      ),
    );
  }

  Widget _softBlob({
    required Alignment alignment,
    required Color color,
    required double size,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 120,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassSquareButton({
    required double size,
    required IconData icon,
    required String hoverLabel,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.70);

    final fill = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.55);

    final iconColor =
        isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF7B2CFF);

    return _HoverGrowSquare(
      size: size,
      onTap: onTap,
      childBuilder: (hovered) {
        final s = hovered ? size * 1.07 : size;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: s,
          height: s,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: fill,
            border: Border.all(color: border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                blurRadius: hovered ? 30 : 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: s * 0.38, color: iconColor),
              if (hovered) ...[
                const SizedBox(height: 8),
                Text(
                  hoverLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xFF3A2A5E),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarStack(double size) {
    final data = _avatarData!;
    final gender = data['gender'];
    final skinTone = data['skinTone'];
    final eye = data['eye'];
    final eyeColor = _hexToColor(data['eyeColor']);
    final hair = data['hair'];
    final hairColor = _hexToColor(data['hairColor']);
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
        // Hair
        if (hair != null && hair != 'null')
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              hairColor,
              BlendMode.modulate,
            ),
            child: Image.asset(
              'assets/images/$hair.png',
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

class _HoverGrowSquare extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  final Widget Function(bool hovered) childBuilder;

  const _HoverGrowSquare({
    required this.size,
    required this.onTap,
    required this.childBuilder,
  });

  @override
  State<_HoverGrowSquare> createState() => _HoverGrowSquareState();
}

class _HoverGrowSquareState extends State<_HoverGrowSquare> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: widget.onTap,
        child: widget.childBuilder(_hovered),
      ),
    );
  }
}
