import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/day_entry_model.dart';
import '../repositories/calendar_repository.dart' hide ymd;
import '../services/api_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _viewMonth; 
  DateTime _selected = DateTime.now();

  String _note = '';
  String? _photo1;
  String? _photo2;

  final Set<int> _daysWithData = {};

  final CalendarRepository _repo = CalendarRepos.calendar;

  bool get _isToday {
    final now = DateTime.now();
    return ymd(now) == ymd(_selected);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month, 1);
    _loadMonthDots();
    _loadSelectedDay();
  }

  Future<void> _loadMonthDots() async {
    final dots = await _repo.getDaysWithDataInMonth(_viewMonth);
    _daysWithData
      ..clear()
      ..addAll(dots);
    if (mounted) setState(() {});
  }

  Future<void> _loadSelectedDay() async {
    final entry = await _repo.getEntryByDate(_selected);

    if (entry == null) {
      _note = '';
      _photo1 = null;
      _photo2 = null;
    } else {
      _note = entry.note ?? '';
      _photo1 = entry.photo1Path;
      _photo2 = entry.photo2Path;
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveToday() async {
    if (!_isToday) return;

    await _repo.upsertEntry(
      date: _selected,
      note: _note,
      photo1Path: _photo1,
      photo2Path: _photo2,
    );

    await _loadMonthDots();
    if (!mounted) return;
    
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Kaydedildi')));
  }

  Future<void> _deleteTodayEntry() async {
    if (!_isToday) return;

    await _repo.deleteEntryByDate(_selected);

    _note = '';
    _photo1 = null;
    _photo2 = null;

    await _loadMonthDots();
    if (mounted) setState(() {});
  }

  Future<String> _copyToAppDir(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = file.path.split('.').last;
    final name = 'mem_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final target = File('${dir.path}/$name');
    return (await File(file.path).copy(target.path)).path;
  }

  Future<String> _copyLocalFileToAppDir(String path) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = path.split('.').last;
    final name = 'mem_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final target = File('${dir.path}/$name');
    return (await File(path).copy(target.path)).path;
  }

  Future<void> _pickPhoto(int slot) async {
    if (!_isToday) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      final stored = await _copyLocalFileToAppDir(path);

      if (!mounted) return;
      setState(() {
        if (slot == 1) _photo1 = stored;
        if (slot == 2) _photo2 = stored;
      });

      await _repo.upsertEntry(
        date: _selected,
        note: _note,
        photo1Path: _photo1,
        photo2Path: _photo2,
      );
      
      if (!mounted) return;
      await _loadMonthDots();
      return;
    }

    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    final stored = await _copyToAppDir(x);

    if (!mounted) return;
    setState(() {
      if (slot == 1) _photo1 = stored;
      if (slot == 2) _photo2 = stored;
    });

    await _repo.upsertEntry(
      date: _selected,
      note: _note,
      photo1Path: _photo1,
      photo2Path: _photo2,
    );
    
    if (!mounted) return;
    await _loadMonthDots();
  }

  Future<void> _removePhoto(int slot) async {
    if (!_isToday) return;
    setState(() {
      if (slot == 1) _photo1 = null;
      if (slot == 2) _photo2 = null;
    });
    await _saveToday();
  }

  Future<void> _editEntryDialog() async {
    if (!_isToday) return;

    final ctrl = TextEditingController(text: _note);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Günlük Kayıt'),
        content: TextField(
          controller: ctrl,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Düşüncelerinizi yazın...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (ok != true) {
      ctrl.dispose();
      return;
    }

    setState(() => _note = ctrl.text);
    ctrl.dispose();
    await _saveToday();
  }

  static const _bgTop = Color(0xFFF5EEFF);
  static const _bgBottom = Color(0xFFF0E6FF);

  static const _purpleA = Color(0xFF7B2CFF);
  static const _purpleB = Color(0xFFA46BFF);

  static const _card = Colors.white;
  static const _stroke = Color(0xFFEFE4FF);

  static const _muted = Color(0xFF8F7BB7);

  static const _dot = Color(0xFF9E5CFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.2,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final double maxW = c.maxWidth;
              final bool isMobile = maxW < 860;
              final double contentW = maxW < 1180.0 ? maxW : 1180.0;

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
                        _header(),
                        const SizedBox(height: 18),
                        Expanded(
                          child: isMobile
                              ? Column(
                                  children: [
                                    _calendarCard(),
                                    const SizedBox(height: 14),
                                    Expanded(child: _detailCard()),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(flex: 3, child: _calendarCard()),
                                    const SizedBox(width: 14),
                                    Expanded(flex: 2, child: _detailCard()),
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

  Widget _header() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _stroke),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF4A2D7A)),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_purpleA, _purpleB]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _purpleA.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Memoria",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3A2A5E),
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Günlük anlarınız için dijital günlük",
              style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _calendarCard() {
    return _glassCard(
      child: Column(
        children: [
          _monthBar(),
          const SizedBox(height: 8),
          _weekHeader(),
          const SizedBox(height: 8),
          Expanded(child: _monthGrid()),
        ],
      ),
    );
  }

  Widget _monthBar() {
    return Row(
      children: [
        _arrowButton(
          icon: Icons.chevron_left,
          onTap: () async {
            setState(() {
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
              _selected = DateTime(_viewMonth.year, _viewMonth.month, 1);
            });
            await _loadMonthDots();
            await _loadSelectedDay();
          },
        ),
        const SizedBox(width: 10),
        _dropdownPill(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _viewMonth.month,
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem(value: m, child: Text(_monthName(m)));
              }),
              onChanged: (m) async {
                if (m == null) return;
                setState(() {
                  _viewMonth = DateTime(_viewMonth.year, m, 1);
                  _selected = DateTime(_viewMonth.year, _viewMonth.month, 1);
                });
                await _loadMonthDots();
                await _loadSelectedDay();
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        _dropdownPill(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _viewMonth.year,
              items: List.generate(11, (i) {
                final y = DateTime.now().year - 5 + i;
                return DropdownMenuItem(value: y, child: Text("$y"));
              }),
              onChanged: (y) async {
                if (y == null) return;
                setState(() {
                  _viewMonth = DateTime(y, _viewMonth.month, 1);
                  _selected = DateTime(_viewMonth.year, _viewMonth.month, 1);
                });
                await _loadMonthDots();
                await _loadSelectedDay();
              },
            ),
          ),
        ),
        const Spacer(),
        _arrowButton(
          icon: Icons.chevron_right,
          onTap: () async {
            setState(() {
              _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
              _selected = DateTime(_viewMonth.year, _viewMonth.month, 1);
            });
            await _loadMonthDots();
            await _loadSelectedDay();
          },
        ),
      ],
    );
  }

  Widget _weekHeader() {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: labels
          .map(
            (s) => Expanded(
              child: Center(
                child: Text(
                  s,
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _monthGrid() {
    final year = _viewMonth.year;
    final month = _viewMonth.month;

    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Sunday start: DateTime.weekday => Mon=1..Sun=7
    final startOffset = first.weekday % 7; // Sun=>0
    const totalCells = 42;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (_, idx) {
        final dayNum = idx - startOffset + 1;
        final inMonth = dayNum >= 1 && dayNum <= daysInMonth;

        if (!inMonth) return const SizedBox.shrink();

        final d = DateTime(year, month, dayNum);
        final selected = ymd(d) == ymd(_selected);

        final now = DateTime.now();
        final isTodayCell = ymd(d) == ymd(now);

        final hasDot = _daysWithData.contains(dayNum);

        if (isTodayCell) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              setState(() => _selected = d);
              await _loadSelectedDay();
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_purpleA, _purpleB]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _purpleA.withOpacity(0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$dayNum",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Today",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            setState(() => _selected = d);
            await _loadSelectedDay();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF4EEFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: selected
                  ? Border.all(color: Colors.black, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("", style: TextStyle(height: 0)),
                Text(
                  "$dayNum",
                  style: const TextStyle(
                    color: Color(0xFF4A2D7A),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                if (hasDot)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _dot,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailCard() {
    final local = _selected;
    final title = "${local.day} ${_monthName(local.month)}";
    final weekday = _weekdayName(local.weekday);

    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3A2A5E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            weekday,
                            style: const TextStyle(
                              color: _muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isToday)
                            const Text(
                              "✧ Bugün",
                              style: TextStyle(
                                color: _dot,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isToday) _editablePill() else const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.calendar_month, color: _dot, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Fotoğraflar (${(_photo1 != null ? 1 : 0) + (_photo2 != null ? 1 : 0)}/2)",
                  style: const TextStyle(
                    color: _dot,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _photosRow(),
            const SizedBox(height: 16),

            const Row(
              children: [
                Icon(Icons.menu_book_rounded, color: _dot, size: 18),
                SizedBox(width: 8),
                Text(
                  "Günlük Kayıt",
                  style: TextStyle(color: _dot, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _journalBlock()),
          ],
        ),
      ),
    );
  }

  Widget _editablePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E8FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        "Düzenlenebilir",
        style: TextStyle(
          color: _purpleA,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _photosRow() {
    return Row(
      children: [
        Expanded(child: _photoTile(slot: 1, path: _photo1)),
        const SizedBox(width: 12),
        Expanded(child: _photoTile(slot: 2, path: _photo2)),
      ],
    );
  }

  Widget _photoTile({required int slot, required String? path}) {
    final canEdit = _isToday;

    if (path == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: canEdit ? () => _pickPhoto(slot) : null,
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F1FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD6C7FF),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: canEdit ? _dot : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                "Fotoğraf Ekle",
                style: TextStyle(
                  color: canEdit ? _dot : Colors.grey.shade400,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: path.startsWith('http') || path.startsWith('/uploads')
                  ? NetworkImage('${ApiService.baseUrl.replaceAll('/api', '')}$path')
                  : FileImage(File(path)) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (canEdit)
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              children: [
                _miniIconButton(
                  icon: Icons.delete_outline,
                  onTap: () => _removePhoto(slot),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _journalBlock() {
    final canEdit = _isToday;

    if (_note.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canEdit
                ? "No entry yet. Click to add your thoughts..."
                : "No entry for this day",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (canEdit)
            TextButton.icon(
              onPressed: _editEntryDialog,
              icon: const Icon(Icons.add, color: _dot),
              label: const Text(
                "Add Entry",
                style: TextStyle(color: _dot, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              _note,
              style: const TextStyle(
                color: Color(0xFF3A2A5E),
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (canEdit)
          Row(
            children: [
              TextButton.icon(
                onPressed: _editEntryDialog,
                icon: const Icon(Icons.edit, color: _dot),
                label: const Text(
                  "Notu Düzenle",
                  style: TextStyle(color: _dot, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: _deleteTodayEntry,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text(
                  "Sil",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _card.withOpacity(0.86),
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
    );
  }

  Widget _dropdownPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _stroke),
      ),
      child: child,
    );
  }

  Widget _arrowButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _stroke),
        ),
        child: Icon(icon, color: const Color(0xFF4A2D7A)),
      ),
    );
  }

  Widget _miniIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF4A2D7A), size: 18),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[m - 1];
  }

  String _weekdayName(int w) {
    switch (w) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }
}
