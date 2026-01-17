import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/focus_day_model.dart';
import '../models/personal_reminder_model.dart';

import '../repositories/focus_repository.dart';
import '../repositories/api_focus_repository.dart';
import '../services/notification_service.dart';
import 'game_page.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  final FocusRepository _repo = ApiFocusRepository();

  // Timer
  Timer? _ticker;
  Duration _remaining = const Duration(minutes: 25);
  Duration _selectedPreset = const Duration(minutes: 25);
  bool _running = false;

  // Data (daily)
  late Future<FocusDay> _dayF;
  late Future<List<PersonalReminder>> _personalF;

  final TextEditingController _personalCtrl = TextEditingController();

  void _refresh() {
    _dayF = _repo.getToday();
    _personalF = _repo.listTodayReminders();
  }

  @override
  void initState() {
    super.initState();
    _refresh();

    // App açılınca: günlük reset kontrolü repository içinde olmalı (today row ensure + reset if day changed)
    // Notif schedule: app açılınca bir kez re-schedule.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.instance.init();
      await NotificationService.instance.reschedule5HourChecks(repo: _repo);
      if (mounted) setState(_refresh);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _personalCtrl.dispose();
    super.dispose();
  }

  // ---------------- Timer logic ----------------

  void _setPreset(Duration d) {
    if (_running) return;
    setState(() {
      _selectedPreset = d;
      _remaining = d;
    });
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _ticker?.cancel();
        if (mounted) setState(() => _running = false);
        return;
      }
      if (mounted) {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _stop() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _restart() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remaining = _selectedPreset;
    });
  }

  // ---------------- Reminders logic ----------------

  Future<void> _tapHydration() async {
    try {
      final day = await _repo.getToday();
      if (day.hydrationCount >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Su içme hedefi tamamlandı!")),
          );
        }
        return;
      }
      await _repo.setHydrationCount(day.hydrationCount + 1);

      if (!mounted) return;
      setState(_refresh);
      await NotificationService.instance.reschedule5HourChecks(repo: _repo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _tapMovement() async {
    try {
      final day = await _repo.getToday();
      if (day.movementCount >= 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hareket hedefi tamamlandı!")),
          );
        }
        return;
      }
      await _repo.setMovementCount(day.movementCount + 1);

      if (!mounted) return;
      setState(_refresh);
      await NotificationService.instance.reschedule5HourChecks(repo: _repo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _addPersonal() async {
    final text = _personalCtrl.text.trim();
    if (text.isEmpty) return;

    await _repo.addPersonalReminder(text);
    _personalCtrl.clear();

    if (!mounted) return;
    setState(_refresh);
    await NotificationService.instance.reschedule5HourChecks(repo: _repo);
  }

  Future<void> _togglePersonal(PersonalReminder r) async {
    await _repo.togglePersonalReminder(r.id, !r.done);

    if (!mounted) return;
    setState(_refresh);
    await NotificationService.instance.reschedule5HourChecks(repo: _repo);
  }

  Future<void> _deletePersonal(PersonalReminder r) async {
    await _repo.deletePersonalReminder(r.id);

    if (!mounted) return;
    setState(_refresh);
    await NotificationService.instance.reschedule5HourChecks(repo: _repo);
  }

  // ---------------- UI constants (match screenshot vibe) ----------------

  static const _bgTop = Color(0xFFF5EEFF);
  static const _bgBottom = Color(0xFFF0E6FF);

  static const _purpleA = Color(0xFF7B2CFF);
  static const _purpleB = Color(0xFFA46BFF);

  static const _stroke = Color(0xFFEFE4FF);
  static const _cardFill = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF8F7BB7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.25),
            radius: 1.25,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final maxW = c.maxWidth;
              final isMobile = maxW < 980;
              final contentW = maxW < 1180 ? maxW : 1180.0;

              return Center(
                child: SizedBox(
                  width: contentW,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 22,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),
                        const SizedBox(height: 18),
                        Expanded(
                          child: isMobile
                              ? Column(
                                  children: [
                                    Expanded(child: _timerCard()),
                                    const SizedBox(height: 14),
                                    _rightColumn(isMobile: true),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(flex: 3, child: _timerCard()),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 4,
                                      child: _rightColumn(isMobile: false),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.deepPurple.shade300,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  "Back to Diary",
                  style: TextStyle(
                    color: Colors.deepPurple.shade300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Text(
          "Focus Hub",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.deepPurple.shade500,
          ),
        ),
        const SizedBox(width: 10),
        _squareIconButton(
          icon: Icons.sports_esports_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GamePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _timerCard() {
    return _glassCard(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(child: Center(child: _timerCircle())),
          const SizedBox(height: 8),
          if (!_running)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _presetChip(
                  "15m",
                  const Duration(minutes: 15),
                  active: _selectedPreset.inMinutes == 15,
                ),
                const SizedBox(width: 10),
                _presetChip(
                  "25m",
                  const Duration(minutes: 25),
                  active: _selectedPreset.inMinutes == 25,
                ),
                const SizedBox(width: 10),
                _presetChip(
                  "45m",
                  const Duration(minutes: 45),
                  active: _selectedPreset.inMinutes == 45,
                ),
              ],
            )
          else
            const SizedBox(height: 36),
          const SizedBox(height: 18),
          _timerControls(),
          const SizedBox(height: 14),
          Text(
            "Odaklanmaya devam et, harika gidiyorsun!",
            style: TextStyle(
              color: Colors.deepPurple.shade200,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _timerCircle() {
    final mm = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Stack(
      alignment: Alignment.center,
      children: [
        // dotted outer ring
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD9C6FF),
              width: 3,
              style: BorderStyle.solid,
            ),
          ),
        ),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_purpleA, _purpleB]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _purpleA.withOpacity(0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                "$mm:$ss",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timerControls() {
    final primary = _running
        ? _actionButton(
            text: "Durdur",
            icon: Icons.stop_rounded,
            filled: true,
            onTap: _stop,
          )
        : _actionButton(
            text: "Başlat",
            icon: Icons.play_arrow_rounded,
            filled: true,
            onTap: _start,
          );

    final secondary = _actionButton(
      text: "Yeniden Başlat",
      icon: Icons.refresh_rounded,
      filled: false,
      onTap: _restart,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [primary, const SizedBox(width: 12), secondary],
    );
  }

  Widget _rightColumn({required bool isMobile}) {
    return Column(
      children: [
        // top row cards
        if (!isMobile)
          Row(
            children: [
              Expanded(child: _hydrationCard()),
              const SizedBox(width: 14),
              Expanded(child: _movementCard()),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _hydrationCard()),
              const SizedBox(width: 14),
              Expanded(child: _movementCard()),
            ],
          ),
        const SizedBox(height: 14),
        Expanded(child: _personalRemindersCard()),
      ],
    );
  }

  Widget _hydrationCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<FocusDay>(
          future: _dayF,
          builder: (context, snap) {
            final day = snap.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _smallIconBadge(
                      icon: Icons.water_drop_rounded,
                      tint: const Color(0xFF3C7BFF),
                      bg: const Color(0xFFEAF1FF),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Hydration",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(10, (i) {
                    final filled = day != null && i < day.hydrationCount;
                    return InkWell(
                      onTap: _tapHydration,
                      borderRadius: BorderRadius.circular(999),
                      child: _tinyCircle(
                        filled: filled,
                        filledColor: const Color(0xFF3C7BFF),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  "TAP TO FILL",
                  style: TextStyle(
                    color: Colors.deepPurple.shade200,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _movementCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<FocusDay>(
          future: _dayF,
          builder: (context, snap) {
            final day = snap.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _smallIconBadge(
                      icon: Icons.directions_walk_rounded,
                      tint: const Color(0xFF1DB954),
                      bg: const Color(0xFFE9FFEF),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Movement",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(2, (i) {
                    final filled = day != null && i < day.movementCount;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: _tapMovement,
                        borderRadius: BorderRadius.circular(999),
                        child: _tinyCircle(
                          filled: filled,
                          filledColor: const Color(0xFF1DB954),
                          size: 18,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  "30 MIN BLOCKS",
                  style: TextStyle(
                    color: Colors.deepPurple.shade200,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _personalRemindersCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kişisel Hatırlatıcılar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.deepPurple.shade500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _stroke),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _personalCtrl,
                        decoration: InputDecoration(
                          hintText: "What else to remember?",
                          hintStyle: TextStyle(
                            color: Colors.deepPurple.shade200,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addPersonal(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _addPersonal,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purpleA, _purpleB],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _purpleA.withOpacity(0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<PersonalReminder>>(
                future: _personalF,
                builder: (context, snap) {
                  final items = snap.data ?? [];

                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        "No personal reminders yet",
                        style: TextStyle(
                          color: Colors.deepPurple.shade200,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = items[i];
                      return _personalRow(r);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personalRow(PersonalReminder r) {
    return InkWell(
      onTap: () => _togglePersonal(r),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _roundCheck(checked: r.done),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                r.text,
                style: TextStyle(
                  color: Colors.deepPurple.shade500,
                  fontWeight: FontWeight.w800,
                  decoration: r.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              tooltip: "Sil",
              onPressed: () => _deletePersonal(r),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.deepPurple.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Small widgets ----------------

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: _cardFill.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _stroke),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _squareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _stroke),
        ),
        child: Icon(icon, color: Colors.deepPurple.shade400, size: 18),
      ),
    );
  }

  Widget _presetChip(String text, Duration d, {required bool active}) {
    return InkWell(
      onTap: () => _setPreset(d),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFF1E8FF)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _stroke),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.deepPurple.shade500,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(colors: [_purpleA, _purpleB])
              : null,
          color: filled ? null : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: filled ? Colors.transparent : _stroke),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _purpleA.withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: filled ? Colors.white : Colors.deepPurple.shade400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: filled ? Colors.white : Colors.deepPurple.shade400,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallIconBadge({
    required IconData icon,
    required Color tint,
    required Color bg,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, color: tint, size: 18),
    );
  }

  Widget _tinyCircle({
    required bool filled,
    required Color filledColor,
    double size = 14,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? filledColor.withOpacity(0.9) : Colors.transparent,
        border: Border.all(
          color: filled
              ? filledColor.withOpacity(0.9)
              : const Color(0xFFD8CCFF),
          width: 1.6,
        ),
      ),
    );
  }

  Widget _roundCheck({required bool checked}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: checked
            ? const LinearGradient(colors: [_purpleA, _purpleB])
            : null,
        border: Border.all(
          color: checked ? Colors.transparent : Colors.deepPurple.shade200,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : const SizedBox.shrink(),
    );
  }
}
