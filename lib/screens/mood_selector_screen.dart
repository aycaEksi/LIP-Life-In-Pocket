import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mood.dart';
import '../repositories/mood_repository.dart';
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
  final MoodRepository _moodRepo = MoodRepository();

  double energy = 5;
  double happiness = 5;
  double stress = 5;
  bool _isLoading = true;
  int? _todayMoodId; // Bugünkü mood'un ID'si
  String? _aiMotivationMessage; // AI'dan gelen mesaj
  bool _isLoadingAI = false; // AI yükleniyor mu?

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    try {
      final todayMood =
          await _moodRepo.getTodayMoodByUserId(widget.userId ?? 1);
      if (todayMood != null && mounted) {
        setState(() {
          _todayMoodId = todayMood.id;
          energy = todayMood.energy.toDouble();
          happiness = todayMood.happiness.toDouble();
          stress = todayMood.stress.toDouble();
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh Hali Seçimi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Bugün nasıl hissediyorsun?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // AI Motivasyon Mesajı
                      if (_aiMotivationMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.purple.shade200, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome,
                                      color: Colors.purple.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Motivasyon',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _aiMotivationMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_isLoadingAI)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue.shade700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AI motivasyon hazırlanıyor...',
                                style: TextStyle(color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Enerji
                      _buildMoodSlider(
                        label: 'Enerji',
                        value: energy,
                        icon: Icons.flash_on,
                        color: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            energy = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Mutluluk
                      _buildMoodSlider(
                        label: 'Mutluluk',
                        value: happiness,
                        icon: Icons.sentiment_satisfied_alt,
                        color: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            happiness = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Stres
                      _buildMoodSlider(
                        label: 'Stres',
                        value: stress,
                        icon: Icons.warning_amber,
                        color: Colors.red,
                        onChanged: (value) {
                          setState(() {
                            stress = value;
                          });
                        },
                      ),

                      const Spacer(),

                      // Kaydet Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveMood,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Theme Toggle Button - if available
                if (widget.themeManager != null)
                  ThemeToggleButton(themeManager: widget.themeManager!),
              ],
            ),
    );
  }

  Widget _buildMoodSlider({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
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
    );
  }

  Future<String?> _fetchAIMotivation() async {
    try {
      final response = await http.post(/* 
        Uri.parse('http://10.0.2.2:3000/api/motivation'), */
        Uri.parse('http://localhost:3000/api/motivation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'energy': energy.toInt(),
          'happiness': happiness.toInt(),
          'stress': stress.toInt(),
          'note': '',
        }),
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
      final mood = Mood(
        id: _todayMoodId, // Eğer bugün için zaten kayıt varsa ID'yi kullan
        userId: widget.userId ?? 1,
        energy: energy.toInt(),
        happiness: happiness.toInt(),
        stress: stress.toInt(),
      );

      if (_todayMoodId != null) {
        // Güncelleme
        await _moodRepo.updateMood(mood);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ruh halin güncellendi!')),
          );
        }
      } else {
        // Yeni kayıt
        final newId = await _moodRepo.createMood(mood);
        setState(() {
          _todayMoodId = newId;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ruh halin kaydedildi!')),
          );
        }
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
