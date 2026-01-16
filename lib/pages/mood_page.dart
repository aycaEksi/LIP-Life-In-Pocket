import 'dart:async';
import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../services/session_service.dart';
import '../services/utils.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  Timer? _timer;

  // preset parts (indexes)
  int hair = 0;
  int eyes = 0;
  int outfit = 0;

  double? todayMean;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _loadTodayMood();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) return;

    final rows = await AppDb.instance.db.query(
      'avatar_prefs',
      where: 'user_id=?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final r = rows.first;
    setState(() {
      hair = r['hair'] as int;
      eyes = r['eyes'] as int;
      outfit = r['outfit'] as int;
    });
  }

  Future<void> _saveAvatar() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) return;
    await AppDb.instance.db.update(
      'avatar_prefs',
      {'hair': hair, 'eyes': eyes, 'outfit': outfit},
      where: 'user_id=?',
      whereArgs: [uid],
    );
  }

  Future<void> _loadTodayMood() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) return;
    final ymd = todayYMD(DateTime.now());

    final rows = await AppDb.instance.db.query(
      'mood_ratings',
      where: 'user_id=? AND date=?',
      whereArgs: [uid, ymd],
      limit: 1,
    );

    if (rows.isEmpty) {
      setState(() => todayMean = null);
    } else {
      setState(() => todayMean = (rows.first['mean'] as num).toDouble());
    }
  }

  bool get _inWindow {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 22, 0);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return now.isAfter(start) && now.isBefore(end);
  }

  Duration get _timeLeft {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 22, 0);
    if (now.isBefore(start)) return start.difference(now);
    return Duration.zero;
  }

  String _leftText() {
    final d = _timeLeft;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m left';
  }

  String _faceFromMean(double mean) {
    if (mean >= 8) return '😁';
    if (mean >= 6) return '🙂';
    if (mean >= 4) return '😐';
    if (mean >= 2) return '🙁';
    return '😢';
  }

  Future<void> _rateDay() async {
    if (todayMean != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Already rated today.')));
      return;
    }
    if (!_inWindow) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Not yet. ${_leftText()}')));
      return;
    }

    final res = await showDialog<_MoodResult>(
      context: context,
      builder: (_) => const _MoodDialog(),
    );
    if (res == null) return;

    final uid = await SessionService.instance.getUserId();
    if (uid == null) return;

    final mean = (res.social + res.romance + res.success + res.mood) / 4.0;
    final ymd = todayYMD(DateTime.now());

    await AppDb.instance.db.insert('mood_ratings', {
      'user_id': uid,
      'date': ymd,
      'sociality': res.social,
      'romance': res.romance,
      'success': res.success,
      'mood': res.mood,
      'mean': mean,
    });

    setState(() => todayMean = mean);
  }

  @override
  Widget build(BuildContext context) {
    final mean = todayMean;
    final face = mean == null ? '🙂' : _faceFromMean(mean);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(child: Text(face, style: const TextStyle(fontSize: 72))),
            const SizedBox(height: 8),
            Center(
              child: Text(
                mean == null
                    ? 'Not rated today'
                    : 'Today mean: ${mean.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(height: 16),

            // Avatar preset “assets” (starter: just index selectors; later you can swap to real images)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Avatar Designer (preset parts)'),
                    const SizedBox(height: 8),
                    _pickerRow(
                      'Hair',
                      hair,
                      5,
                      (v) => setState(() => hair = v),
                    ),
                    _pickerRow(
                      'Eyes',
                      eyes,
                      5,
                      (v) => setState(() => eyes = v),
                    ),
                    _pickerRow(
                      'Outfit',
                      outfit,
                      5,
                      (v) => setState(() => outfit = v),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveAvatar();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Avatar saved')),
                        );
                      },
                      child: const Text('Design (save)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _rateDay,
              child: Text(_inWindow ? 'Rate the day' : 'Rate the day (locked)'),
            ),
            if (!_inWindow && _timeLeft > Duration.zero)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Too early. ${_leftText()}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow(
    String label,
    int value,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: (max - 1).toDouble(),
            divisions: max - 1,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 28, child: Text('$value')),
      ],
    );
  }
}

class _MoodResult {
  final int social, romance, success, mood;
  _MoodResult(this.social, this.romance, this.success, this.mood);
}

class _MoodDialog extends StatefulWidget {
  const _MoodDialog();

  @override
  State<_MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<_MoodDialog> {
  int social = 5, romance = 5, success = 5, mood = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate your day (0-10)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Sociality', social, (v) => setState(() => social = v)),
          _row('Romance', romance, (v) => setState(() => romance = v)),
          _row('Success', success, (v) => setState(() => success = v)),
          _row('Mood', mood, (v) => setState(() => mood = v)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            _MoodResult(social, romance, success, mood),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _row(String label, int val, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: Slider(
            value: val.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$val',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(width: 28, child: Text('$val')),
      ],
    );
  }
}
