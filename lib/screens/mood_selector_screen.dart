import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/mood.dart';
import '../services/api_service.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';

class MoodSelectorScreen extends StatefulWidget {
  final int? userId;
  final ThemeManager? themeManager;

  const MoodSelectorScreen({this.userId, this.themeManager, super.key});

  @override
  State<MoodSelectorScreen> createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen> {
  double energy = 5;
  double happiness = 5;
  double stress = 5;
  bool _isLoading = true;
  bool _hasTodayMood = false;
  String? _aiMotivationMessage;
  bool _isLoadingAI = false;

  // Theme constants (close to reference design)
  static const _bgTopLight = Color(0xFFF6EEFF);
  static const _bgBottomLight = Color(0xFFF2ECFF);
  static const _bgTopDark = Color(0xFF140824);
  static const _bgBottomDark = Color(0xFF0B0516);

  static const _purpleA = Color(0xFF7B2CFF);
  static const _purpleB = Color(0xFFA46BFF);

  static const _muted = Color(0xFF8F7BB7);
  static const _cardStroke = Color(0xFFEDE5FF);

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    try {
      final response = await ApiService.instance.getMoods(limit: 1);
      
      if (response.statusCode == 200) {
        final moodsList = jsonDecode(response.body) as List;
        if (mounted && moodsList.isNotEmpty) {
          final data = moodsList.first;
          setState(() {
            _hasTodayMood = true;
            energy = (data['energy'] ?? 5).toDouble();
            happiness = (data['happiness'] ?? 5).toDouble();
            stress = (data['stress'] ?? 5).toDouble();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _topBar(context),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 22),
                                  _headerBlock(isDark),
                                  const SizedBox(height: 34),
                                  if (_aiMotivationMessage != null)
                                    _aiBox(
                                      isDark: isDark,
                                      title: "AI Motivation",
                                      text: _aiMotivationMessage!,
                                    ),
                                  if (_isLoadingAI) _aiLoadingBox(isDark),
                                  const SizedBox(height: 10),
                                  _metricBlock(
                                    isDark: isDark,
                                    icon: Icons.bolt_rounded,
                                    iconColor: const Color(0xFFFFA02D),
                                    label: "Energy",
                                    value: energy,
                                    valueColor: const Color(0xFFFFA02D),
                                    onChanged: (v) =>
                                        setState(() => energy = v),
                                  ),
                                  const SizedBox(height: 26),
                                  _metricBlock(
                                    isDark: isDark,
                                    icon: Icons.favorite_border_rounded,
                                    iconColor: const Color(0xFF20B16A),
                                    label: "Happiness",
                                    value: happiness,
                                    valueColor: const Color(0xFF20B16A),
                                    onChanged: (v) =>
                                        setState(() => happiness = v),
                                  ),
                                  const SizedBox(height: 26),
                                  _metricBlock(
                                    isDark: isDark,
                                    icon: Icons.error_outline_rounded,
                                    iconColor: const Color(0xFFFF2D55),
                                    label: "Stress",
                                    value: stress,
                                    valueColor: const Color(0xFFFF2D55),
                                    onChanged: (v) =>
                                        setState(() => stress = v),
                                  ),
                                  const SizedBox(height: 46),
                                  _saveButton(isDark),
                                  const SizedBox(height: 36),
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
          if (widget.themeManager != null)
            ThemeToggleButton(themeManager: widget.themeManager!),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back, color: _purpleA),
            ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
          const Text(
            "Daily Reflection",
            style: TextStyle(
              color: _purpleA,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _headerBlock(bool isDark) {
    return Column(
      children: [
        Text(
          "How do you feel today?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            fontFamily: 'serif',
            color: isDark ? Colors.white : const Color(0xFF2B2338),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Take a moment to check in with yourself.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white60 : _muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _metricBlock({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
    required Color valueColor,
    required ValueChanged<double> onChanged,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white12 : _cardStroke,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF2B2338),
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: _purpleB,
              inactiveTrackColor: _purpleB.withOpacity(0.22),
              thumbColor: Colors.white,
              overlayColor: _purpleA.withOpacity(0.10),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _saveMood,
        child: Container(
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _purpleB,
            boxShadow: [
              BoxShadow(
                color: _purpleA.withOpacity(isDark ? 0.25 : 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.save_outlined, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                "Save Reflection",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiBox({
    required bool isDark,
    required String title,
    required String text,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.76),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : _cardStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: _purpleA, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF2B2338),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF3A2A5E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiLoadingBox(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.76),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : _cardStroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white70 : _purpleA,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Preparing AI motivation...',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fetchAIMotivation() async {
    try {
      final response = await ApiService.instance.getMotivation(
        energy: energy.toInt(),
        happiness: happiness.toInt(),
        stress: stress.toInt(),
        note: '',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] as String?;
      } else {
        debugPrint('AI servisi hatası: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('AI servisi bağlantı hatası: $e');
      return null;
    }
  }

  Future<void> _saveMood() async {
    try {
      // API'ye mood kaydet
      final response = await ApiService.instance.saveMood(
        energy: energy.toInt(),
        happiness: happiness.toInt(),
        stress: stress.toInt(),
        note: '',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _hasTodayMood = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_hasTodayMood ? 'Ruh halin güncellendi!' : 'Ruh halin kaydedildi!')),
          );
        }

        // AI motivasyon mesajı al
        if (mounted) {
          setState(() {
            _isLoadingAI = true;
            _aiMotivationMessage = null;
          });
        }

        final aiMessage = await _fetchAIMotivation();

        if (mounted) {
          setState(() {
            _isLoadingAI = false;
            _aiMotivationMessage = aiMessage ?? 'Motivasyon mesajı alınamadı.';
          });
        }
      } else {
        throw Exception('Mood kaydedilemedi: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAI = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
