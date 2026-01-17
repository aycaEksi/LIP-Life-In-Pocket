import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _rand = Random();

  static const List<String> trKeys = [
    "Q",
    "W",
    "E",
    "R",
    "T",
    "Y",
    "U",
    "I",
    "O",
    "P",
    "Ğ",
    "Ü",
    "A",
    "S",
    "D",
    "F",
    "G",
    "H",
    "J",
    "K",
    "L",
    "Ş",
    "İ",
    "Z",
    "X",
    "C",
    "V",
    "B",
    "N",
    "M",
    "Ö",
    "Ç",
  ];
  static const int maxTries = 5;
  int? _size;
  bool _started = false;
  bool _won = false;
  bool _gameOver = false;
  String _secret = "";
  String _status = "Choose a size (4/5/6) and press Start.";

  bool _dictLoaded = false;
  final Set<String> _dictAll = {};
  final Map<int, List<String>> _byLength = {4: [], 5: [], 6: []};

  int _row = 0;
  int _col = 0;
  late List<List<String>> _grid;
  late List<List<_CellState>> _colors;

  // UI Colors (reddish/coral theme)
  static const Color _redA = Color(0xFFFF6B5B);
  static const Color _redB = Color(0xFFFF8F5E);
  static const Color _bgTop = Color(0xFFFFF5F3);
  static const Color _bgBottom = Color(0xFFFFEAE3);
  static const Color _stroke = Color(0xFFFFD9CC);
  static const Color _card = Colors.white;
  static const Color _muted = Color(0xFFC07668);

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    try {
      final raw = await rootBundle.loadString('assets/tr_words.txt');
      String fixI(String s) => s.replaceAll('i\u0307', 'i');
      final lines = raw
          .split(RegExp(r'\r?\n'))
          .map((s) => fixI(s.trim().toLowerCase()))
          .where((s) => s.isNotEmpty)
          .toList();

      _dictAll.clear();
      _byLength[4]!.clear();
      _byLength[5]!.clear();
      _byLength[6]!.clear();

      for (final w in lines) {
        if (w.length >= 4 && w.length <= 6) {
          _dictAll.add(w);
          if (_byLength.containsKey(w.length)) _byLength[w.length]!.add(w);
        }
      }
      setState(() {
        _dictLoaded = true;
        _status = "Dictionary loaded. Choose a size:";
      });
    } catch (_) {
      setState(() {
        _dictLoaded = false;
        _status = "Dictionary missing.";
      });
    }
  }

  void _start() {
    if (!_dictLoaded) {
      setState(() => _status = "Dictionary missing!");
      return;
    }
    if (!(_size == 4 || _size == 5 || _size == 6)) {
      setState(() => _status = "pick one of the sizes: 4, 5, 6.");
      return;
    }
    final pool = _byLength[_size]!;
    if (pool.isEmpty) {
      setState(() => _status = "No words of lenth $_size in dictionary.");
      return;
    }
    final secret = pool[_rand.nextInt(pool.length)];
    _grid = List.generate(maxTries, (_) => List.filled(_size!, ""));
    _colors = List.generate(
      maxTries,
      (_) => List.filled(_size!, _CellState.empty),
    );
    setState(() {
      _secret = secret;
      _started = true;
      _gameOver = false;
      _won = false;
      _row = 0;
      _col = 0;
      _status = "Type your guess";
    });
  }

  void _reset() {
    setState(() {
      _started = false;
      _gameOver = false;
      _won = false;
      _secret = "";
      _size = null;
      _status = "Choose a size (4/5/6) and press Start.";
    });
  }

  void _addLetter(String upper) {
    if (!_started || _gameOver) return;
    if (_col >= _size!) return;
    String lowerTr(String s) {
      if (s == "I") return "ı";
      if (s == "İ") return "i";
      return s.toLowerCase();
    }

    final letter = lowerTr(upper);
    setState(() {
      _grid[_row][_col] = letter;
      _col++;
    });
  }

  void _backspace() {
    if (!_started || _gameOver) return;
    if (_col <= 0) return;

    setState(() {
      _col--;
      _grid[_row][_col] = "";
    });
  }

  void _guess() {
    if (!_started || _gameOver) return;
    if (_col != _size) {
      setState(() => _status = "Fill all $_size letters.");
      return;
    }
    final guess = _grid[_row].join();
    if (!_dictAll.contains(guess)) {
      setState(() => _status = "Not a valid Turkish word.");
      return;
    }
    final secretChars = _secret.split('');
    final guessChars = guess.split('');
    final result = List.filled(_size!, _CellState.absent);
    final counts = <String, int>{};
    for (int i = 0; i < _size!; i++) {
      if (guessChars[i] == secretChars[i]) {
        result[i] = _CellState.correct;
      } else {
        counts[secretChars[i]] = (counts[secretChars[i]] ?? 0) + 1;
      }
    }

    for (int i = 0; i < _size!; i++) {
      if (result[i] == _CellState.correct) continue;
      final g = guessChars[i];
      final c = counts[g] ?? 0;
      if (c > 0) {
        result[i] = _CellState.present;
        counts[g] = c - 1;
      }
    }

    setState(() {
      for (int i = 0; i < _size!; i++) {
        _colors[_row][i] = result[i];
      }
    });

    if (guess == _secret) {
      setState(() {
        _won = true;
        _gameOver = true;
        _status = "Congrats, you won! 🥳";
      });
      return;
    }
    if (_row == maxTries - 1) {
      setState(() {
        _gameOver = true;
        _status = "You lost! You can try again🤗\nThe word was: $_secret";
      });
      return;
    }

    setState(() {
      _col = 0;
      _row++;
      _status = "Guess again.";
    });
  }

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
                        _header(context),
                        const SizedBox(height: 18),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _controlsCard(),
                                const SizedBox(height: 18),
                                if (_started) ...[
                                  _Board(
                                    grid: _grid,
                                    colors: _colors,
                                    size: _size!,
                                  ),
                                  const SizedBox(height: 18),
                                  _actionsCard(),
                                  const SizedBox(height: 18),
                                  _TurkishKey(
                                    onKey: _gameOver ? null : _addLetter,
                                    disabled: !_started,
                                  ),
                                ] else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Text(
                                      _dictLoaded
                                          ? "Select size to start"
                                          : "Loading dictionary...",
                                      style: const TextStyle(
                                        color: _muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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
          child: Container(
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
            child: Icon(
              Icons.arrow_back,
              color: Color.lerp(_redA, _redB, 0.5),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Wordlook",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _redA,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Türkçe kelime bulma oyunu",
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: _card.withOpacity(0.86),
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
          child: child,
        ),
      ),
    );
  }

  Widget _controlsCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Oyun Kontrolleri",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _redA,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _stroke),
                    ),
                    child: DropdownButton<int>(
                      value: _size,
                      hint: const Text("Kelime Uzunluğu", style: TextStyle(color: _muted)),
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: const [4, 5, 6]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text("$v letters"),
                            ),
                          )
                          .toList(),
                      onChanged: _started
                          ? null
                          : (v) => setState(() => _size = v),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: (_started || !_dictLoaded) ? null : _start,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_redA, _redB]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _redA.withOpacity(0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      _dictLoaded ? "Başlat" : "Yüklüyor",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _redA.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _redA.withOpacity(0.2)),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  color: _redA,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            if (_started)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _reset,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionsCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _gameOver ? null : _guess,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_redA, _redB]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _redA.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  "Tahmini Gönder",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _gameOver ? null : _backspace,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _stroke),
                ),
                child: const Text(
                  "⌫ Sil",
                  style: TextStyle(
                    color: _redA,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CellState { empty, correct, present, absent }

class _Board extends StatelessWidget {
  final List<List<String>> grid;
  final List<List<_CellState>> colors;
  final int size;

  const _Board({required this.grid, required this.colors, required this.size});

  Color _bg(_CellState s) {
    switch (s) {
      case _CellState.correct:
        return const Color(0xFF21B45B);
      case _CellState.present:
        return const Color(0xFFFFB81C);
      case _CellState.absent:
        return Colors.grey.shade400;
      case _CellState.empty:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(grid.length, (r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(size, (c) {
              final letter = grid[r][c];
              final state = colors[r][c];

              return Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _bg(state),
                  border: Border.all(
                    color: state == _CellState.empty
                        ? const Color(0xFFFFD9CC)
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: state == _CellState.empty
                      ? null
                      : [
                          BoxShadow(
                            color: _bg(state).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Text(
                  letter.isEmpty ? "" : letter.toLowerCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _TurkishKey extends StatelessWidget {
  final void Function(String upper)? onKey;
  final bool disabled;

  const _TurkishKey({required this.onKey, required this.disabled});

  static const rows = [
    ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "Ğ", "Ü"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ş", "İ"],
    ["Z", "X", "C", "V", "B", "N", "M", "Ö", "Ç"],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: row.map((k) {
              return SizedBox(
                width: 42,
                height: 42,
                child: InkWell(
                  onTap: (disabled || onKey == null) ? null : () => onKey!(k),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: (disabled || onKey == null)
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFFF6B5B), Color(0xFFFF8F5E)],
                            ),
                      color: (disabled || onKey == null)
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: (disabled || onKey == null)
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFFFF6B5B).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        k,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: (disabled || onKey == null)
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
