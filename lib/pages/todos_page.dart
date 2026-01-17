import 'dart:ui';
import 'package:flutter/material.dart';

import '../repositories/todos_repository.dart';
import '../models/task_models.dart';

enum Period { daily, weekly, monthly, yearly }

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  Period _period = Period.daily;

  final TextEditingController _newTaskCtrl = TextEditingController();
  DateTime? _newTaskDue; // optional

  @override
  void dispose() {
    _newTaskCtrl.dispose();
    super.dispose();
  }

  String _periodLabel(Period p) {
    switch (p) {
      case Period.daily:
        return "Günlük";
      case Period.weekly:
        return "Haftalık";
      case Period.monthly:
        return "Aylık";
      case Period.yearly:
        return "Yıllık";
    }
  }

  String _periodDb(Period p) => p.name; 


  Future<List<TaskItem>> _loadTasks() async {
    return Repos.todos.getTasks(_periodDb(_period));
  }

  Future<void> _addTask() async {
    final title = _newTaskCtrl.text.trim();
    if (title.isEmpty) return;

    await Repos.todos.addTask(_periodDb(_period), title, _newTaskDue);

    _newTaskCtrl.clear();
    _newTaskDue = null;
    if (mounted) setState(() {});
  }

  Future<void> _toggleDone(int id, bool done) async {
    await Repos.todos.toggleDone(id, !done);
    if (mounted) setState(() {});
  }

  Future<void> _deleteTask(int id) async {
    await Repos.todos.deleteTask(id);
    if (mounted) setState(() {});
  }

  Future<void> _editTask({
    required int id,
    required String currentTitle,
    required DateTime? currentDue,
  }) async {
    final ctrl = TextEditingController(text: currentTitle);
    DateTime? due = currentDue;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text("Edit task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      labelText: "Task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickDueDateTime(initial: due);
                            if (picked == null) return;
                            setDialogState(() => due = picked);
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("Due date"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: "Clear",
                        onPressed: () => setDialogState(() => due = null),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      due == null ? "No due date" : _prettyDue(due!),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    final newTitle = ctrl.text.trim();
    if (newTitle.isEmpty) return;

    await Repos.todos.updateTask(id, newTitle, due);
    if (mounted) setState(() {});
  }


  Future<DateTime?> _pickDueDateTime({DateTime? initial}) async {
    final now = DateTime.now();
    final init = initial ?? now;

    final d = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (d == null) return null;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
    );
    if (t == null) {
      return DateTime(d.year, d.month, d.day, 12, 0);
    }
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  String _prettyDue(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return "$dd/$mm/${dt.year} • $h:$m";
  }

  String _chipText(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d0 = DateTime(due.year, due.month, due.day);

    if (d0 == today.add(const Duration(days: 1))) return "Tomorrow";
    if (d0 == today) {
      final hour = due.hour % 12 == 0 ? 12 : due.hour % 12;
      final ampm = due.hour >= 12 ? "PM" : "AM";
      final min = due.minute.toString().padLeft(2, '0');
      return "$hour:$min $ampm";
    }
    final mm = due.month.toString().padLeft(2, '0');
    final dd = due.day.toString().padLeft(2, '0');
    return "$dd/$mm";
  }

  static const _bgLavenderTop = Color(0xFFF3ECFF);
  static const _bgLavenderBottom = Color(0xFFE9DBFF);

  static const _purpleA = Color(0xFF7B2CFF);
  static const _purpleB = Color(0xFFA46BFF);
  static const _card = Color(0xFFF9F6FF);
  static const _stroke = Color(0xFFE9DAFF);

  static const _chipAmber = Color(0xFFFFE3B1);
  static const _chipAmberText = Color(0xFF9A6200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // background gradient like first photo
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [_bgLavenderTop, _bgLavenderBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final double maxW = c.maxWidth;
              final double contentW = maxW < 980.0 ? maxW : 980.0;
              final isMobile = maxW < 700;

              return Center(
                child: SizedBox(
                  width: contentW,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 26,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        _topHeader(),
                        const SizedBox(height: 16),
                        _periodSelector(isMobile: isMobile),
                        const SizedBox(height: 18),
                        Expanded(
                          child: FutureBuilder<List<TaskItem>>(
                            future: _loadTasks(),
                            builder: (context, snap) {
                              final rows = snap.data ?? [];
                              final total = rows.length;
                              final doneCount = rows
                                  .where((t) => t.done)
                                  .length;

                              return Column(
                                children: [
                                  _focusCardHeader(
                                    doneCount: doneCount,
                                    total: total,
                                    isMobile: isMobile,
                                  ),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: _tasksCard(
                                      rows: rows,
                                      isMobile: isMobile,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _bottomAddBar(isMobile: isMobile),
                                ],
                              );
                            },
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

  Widget _topHeader() {
    return Row(
      children: [
        // Back button (NEW)
        _iconSquareButton(
          icon: Icons.arrow_back,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Tempo",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurple.shade400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(" ", style: TextStyle(color: Colors.deepPurple.shade200)),
            ],
          ),
        ),
        _iconSquareButton(
          icon: Icons.rocket_launch_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimeCapsulePage()),
            );
          },
        ),
      ],
    );
  }

  Widget _iconSquareButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.deepPurple.shade400),
      ),
    );
  }

  Widget _periodSelector({required bool isMobile}) {
    // pill segmented control like photo
    const items = Period.values;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((p) {
          final active = p == _period;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: active
                      ? const LinearGradient(colors: [_purpleA, _purpleB])
                      : null,
                  color: active ? null : Colors.transparent,
                ),
                child: Text(
                  _periodLabel(p),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : Colors.deepPurple.shade400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _focusCardHeader({
    required int doneCount,
    required int total,
    required bool isMobile,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        total == 0 ? "0 tasks" : "$doneCount of $total tasks completed",
        style: TextStyle(
          color: Colors.deepPurple.shade300,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tasksCard({required List<TaskItem> rows, required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Günün Görevleri",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple.shade400,
                    ),
                  ),
                ),
                _smallPill(text: "${_periodLabel(_period)} View"),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: rows.isEmpty
                  ? Center(
                      child: Text(
                        "No tasks yet.",
                        style: TextStyle(color: Colors.deepPurple.shade200),
                      ),
                    )
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final t = rows[i];
                        return _taskRow(
                          id: t.id,
                          title: t.title,
                          done: t.done,
                          due: t.dueDate,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallPill({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _stroke),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.deepPurple.shade300,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _taskRow({
    required int id,
    required String title,
    required bool done,
    required DateTime? due,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _editTask(id: id, currentTitle: title, currentDue: due),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
        ),
        child: Row(
          children: [
            _roundCheck(checked: done, onTap: () => _toggleDone(id, done)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.w600,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (due != null) ...[
              const SizedBox(width: 8),
              _dueChip(_chipText(due)),
            ],
            const SizedBox(width: 8),
            IconButton(
              tooltip: "Delete",
              onPressed: () => _deleteTask(id),
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

  Widget _roundCheck({required bool checked, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: checked ? Colors.transparent : Colors.deepPurple.shade200,
            width: 2,
          ),
          gradient: checked
              ? const LinearGradient(colors: [_purpleA, _purpleB])
              : null,
          color: checked ? null : Colors.transparent,
        ),
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _dueChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _chipAmber,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _chipAmber.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: _chipAmberText),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _chipAmberText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomAddBar({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _stroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newTaskCtrl,
              decoration: InputDecoration(
                hintText: "Yeni görev ekle...",
                hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: "Pick due date",
            onPressed: () async {
              final picked = await _pickDueDateTime(initial: _newTaskDue);
              if (picked == null) return;
              setState(() => _newTaskDue = picked);
            },
            icon: Icon(Icons.calendar_month, color: Colors.deepPurple.shade300),
          ),
          if (_newTaskDue != null) ...[
            const SizedBox(width: 4),
            _dueChip(_chipText(_newTaskDue!)),
            const SizedBox(width: 6),
            IconButton(
              tooltip: "Clear due date",
              onPressed: () => setState(() => _newTaskDue = null),
              icon: Icon(Icons.close, color: Colors.deepPurple.shade200),
            ),
          ],
          const SizedBox(width: 8),
          InkWell(
            onTap: _addTask,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 14 : 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_purpleA, _purpleB]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _purpleA.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    "Ekle",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class TimeCapsulePage extends StatefulWidget {
  const TimeCapsulePage({super.key});

  @override
  State<TimeCapsulePage> createState() => _TimeCapsulePageState();
}

class _TimeCapsulePageState extends State<TimeCapsulePage> {
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime? _unlockAt;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCapsule() async {
    final msg = _noteCtrl.text.trim();
    if (msg.isEmpty || _unlockAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir mesaj yazın ve tarih seçin.")),
      );
      return;
    }

    try {
      await Repos.todos.addCapsule(msg, _unlockAt!);
      _noteCtrl.clear();
      _unlockAt = null;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Zaman kapsülü oluşturuldu!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _deleteCapsule(CapsuleItem capsule) async {
    try {
      await Repos.todos.deleteCapsule(capsule.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kapsül silindi")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<List<CapsuleItem>> _loadCapsules() async {
    return Repos.todos.getCapsules();
  }

  Future<void> _pickUnlock() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 60)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 10),
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    final dt = t == null
        ? DateTime(d.year, d.month, d.day, 12, 0)
        : DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() => _unlockAt = dt);
  }

  String _prettyDate(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return "$mm/$dd/${dt.year}";
  }

  static const _blueTop = Color(0xFFEAF7FF);
  static const _blueBottom = Color(0xFFD9F0FF);
  static const _blueA = Color(0xFF2E6BFF);
  static const _blueB = Color(0xFF2EC6FF);
  static const _capsStroke = Color(0xFFD6E8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.2,
            colors: [_blueTop, _blueBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final double maxW = c.maxWidth;
              final double contentW = maxW < 1000.0 ? maxW : 1000.0;
              final isMobile = maxW < 760;

              return Center(
                child: SizedBox(
                  width: contentW,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 26,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        _capsuleHeader(),
                        const SizedBox(height: 18),
                        _createCapsuleCard(isMobile: isMobile),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Kilitli Zaman Kapsüllerin",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: FutureBuilder<List<CapsuleItem>>(
                            future: _loadCapsules(),
                            builder: (context, snap) {
                              final rows = snap.data ?? [];
                              if (rows.isEmpty) {
                                return Center(
                                  child: Text(
                                    "Henüz bir zaman kapsülün yok.",
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                    ),
                                  ),
                                );
                              }

                              final cols = isMobile ? 1 : 2;
                              return GridView.builder(
                                itemCount: rows.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      childAspectRatio: isMobile ? 3.2 : 3.6,
                                    ),
                                itemBuilder: (_, i) {
                                  final cap = rows[i];
                                  final unlockUtc = cap.unlockAtUtc;
                                  final unlocked = cap.isUnlocked;
                                  final unlockLocal = unlockUtc.toLocal();

                                  return _capsuleTile(
                                    capsule: cap,
                                    unlockLocal: unlockLocal,
                                    unlocked: unlocked,
                                    note: cap.note,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your capsules will unlock automatically on their set dates",
                          style: TextStyle(color: Colors.blue.shade300),
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

  Widget _capsuleHeader() {
    return Row(
      children: [
        _squareBackButton(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Zaman Kapsülü",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "✧ Gelecekteki kendine mesajlar",
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _squareBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
      ),
    );
  }

  Widget _createCapsuleCard({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _capsStroke),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              Text(
                "Yeni Zaman Kapsülü Oluştur",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            children: [
              Expanded(
                flex: isMobile ? 0 : 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _capsStroke),
                  ),
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Gelecekteki kendine bir mesaj yaz...",
                      hintStyle: TextStyle(color: Colors.blue.shade200),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 0 : 14, height: isMobile ? 12 : 0),
              Expanded(
                flex: isMobile ? 0 : 2,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _capsStroke),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _unlockAt == null
                                    ? "mm/dd/yyyy"
                                    : _prettyDate(_unlockAt!),
                                style: TextStyle(
                                  color: _unlockAt == null
                                      ? Colors.blue.shade200
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _pickUnlock,
                              icon: Icon(
                                Icons.edit_calendar,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _addCapsule,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_blueA, _blueB],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _blueA.withOpacity(0.22),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Kapsül Oluştur",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _capsuleTile({
    required CapsuleItem capsule,
    required DateTime unlockLocal,
    required bool unlocked,
    required String note,
  }) {
    final monthName = _monthName(unlockLocal.month).toUpperCase();
    final label = unlocked
        ? "UNLOCKED"
        : "ŞU ZAMANA KADAR KİLİTLİ: $monthName ${unlockLocal.day}, ${unlockLocal.year}";

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        if (!unlocked) {
          return;
        }
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Unlocked capsule"),
            content: SelectableText(note),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _capsStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              color: Colors.blue.shade500,
              size: 34,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lockChip(label),
                  const SizedBox(height: 10),
                  _hiddenMessageLine(unlocked: unlocked, text: note),
                ],
              ),
            ),
            if (unlocked)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () => _deleteCapsule(capsule),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _lockChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _capsStroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 14, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hiddenMessageLine({required bool unlocked, required String text}) {
    final shown = unlocked ? text : "Hidden message";
    final base = Text(
      shown,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.blue.shade300,
        fontWeight: FontWeight.w700,
      ),
    );

    if (unlocked) return base;

    return ClipRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: base,
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[m - 1];
  }
}
