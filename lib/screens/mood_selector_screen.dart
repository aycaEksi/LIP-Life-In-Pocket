import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../repositories/mood_repository.dart';

class MoodSelectorScreen extends StatefulWidget {
  final int? userId;

  const MoodSelectorScreen({this.userId, super.key});

  @override
  State<MoodSelectorScreen> createState() => _MoodSelectorScreenState();
}

class _MoodSelectorScreenState extends State<MoodSelectorScreen> {
  final MoodRepository _moodRepo = MoodRepository();

  double energy = 5;
  double happiness = 5;
  double stress = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh Hali Seçimi'),
        centerTitle: true,
      ),
      body: Padding(
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
            const SizedBox(height: 40),

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

  Future<void> _saveMood() async {
    try {
      final mood = Mood(
        userId: widget.userId ?? 1, // TODO: Gerçek user ID'yi kullan
        energy: energy.toInt(),
        happiness: happiness.toInt(),
        stress: stress.toInt(),
      );

      await _moodRepo.createMood(mood);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruh halin kaydedildi!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
