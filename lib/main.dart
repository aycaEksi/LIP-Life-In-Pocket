import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.load();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;

  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
      ),
      home: MainScreen(appState: appState),
    );
  }
}

/// ---------- DATA & STATE ----------

enum TaskScope { daily, weekly, monthly, yearly }

class Task {
  String id;
  String title;
  TaskScope scope;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.scope,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scope': scope.index,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        scope: TaskScope.values[json['scope'] as int],
        isDone: json['isDone'] as bool? ?? false,
      );
}

class MoodEntry {
  String date; // yyyy-MM-dd
  int success;
  int sociability;
  int mood;

  MoodEntry({
    required this.date,
    required this.success,
    required this.sociability,
    required this.mood,
  });

  double get average => (success + sociability + mood) / 3.0;

  Map<String, dynamic> toJson() => {
        'date': date,
        'success': success,
        'sociability': sociability,
        'mood': mood,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: json['date'] as String,
        success: json['success'] as int,
        sociability: json['sociability'] as int,
        mood: json['mood'] as int,
      );
}

class AppState {
  List<Task> tasks;
  Map<String, String> notesByDate; // key: yyyy-MM-dd
  List<MoodEntry> moods;

  AppState({
    required this.tasks,
    required this.notesByDate,
    required this.moods,
  });

  /// Load from SharedPreferences
  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Tasks
    final tasksString = prefs.getString('tasks');
    List<Task> tasks = [];
    if (tasksString != null) {
      final decoded = jsonDecode(tasksString) as List<dynamic>;
      tasks =
          decoded.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Notes
    final notesString = prefs.getString('notes');
    Map<String, String> notes = {};
    if (notesString != null) {
      final decoded = jsonDecode(notesString) as Map<String, dynamic>;
      notes = decoded.map(
        (k, v) => MapEntry(k, v as String),
      );
    }

    // Moods
    final moodsString = prefs.getString('moods');
    List<MoodEntry> moods = [];
    if (moodsString != null) {
      final decoded = jsonDecode(moodsString) as List<dynamic>;
      moods = decoded
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return AppState(tasks: tasks, notesByDate: notes, moods: moods);
  }

  /// Helpers
  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// TASKS ---------------
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(list));
  }

  void addTask(String title, TaskScope scope) {
    tasks.add(Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      scope: scope,
    ));
    _saveTasks();
  }

  void toggleTask(String id, bool isDone) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].isDone = isDone;
      _saveTasks();
    }
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    _saveTasks();
  }

  /// NOTES ---------------
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notesByDate));
  }

  String getNoteForDate(DateTime date) {
    return notesByDate[_dateKey(date)] ?? '';
  }

  void setNoteForDate(DateTime date, String note) {
    final key = _dateKey(date);
    if (note.trim().isEmpty) {
      notesByDate.remove(key);
    } else {
      notesByDate[key] = note;
    }
    _saveNotes();
  }

  /// MOODS ---------------
  Future<void> _saveMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final list = moods.map((m) => m.toJson()).toList();
    await prefs.setString('moods', jsonEncode(list));
  }

  MoodEntry? getMoodForDate(DateTime date) {
    final key = _dateKey(date);
    try {
      return moods.firstWhere((m) => m.date == key);
    } catch (_) {
      return null;
    }
  }

  void setMoodForDate(DateTime date, int success, int sociability, int mood) {
    final key = _dateKey(date);
    moods.removeWhere((m) => m.date == key);
    moods.add(MoodEntry(
      date: key,
      success: success,
      sociability: sociability,
      mood: mood,
    ));
    _saveMoods();
  }
}

/// ---------- MAIN SCREEN WITH BOTTOM NAV ----------

class MainScreen extends StatefulWidget {
  final AppState appState;

  const MainScreen({super.key, required this.appState});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TasksPage(appState: widget.appState),
      CalendarPage(appState: widget.appState),
      AvatarPage(appState: widget.appState),
    ];

    final titles = [
      'LiP – Tasks',
      'LiP – Calendar',
      'LiP – Avatar',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined), // notebook
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Avatar',
          ),
        ],
      ),
    );
  }
}

/// ---------- TASKS PAGE (DAILY/WEEKLY/MONTHLY/YEARLY) ----------

class TasksPage extends StatelessWidget {
  final AppState appState;

  const TasksPage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
                Tab(text: 'Yearly'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              children: [
                TaskList(appState: appState, scope: TaskScope.daily),
                TaskList(appState: appState, scope: TaskScope.weekly),
                TaskList(appState: appState, scope: TaskScope.monthly),
                TaskList(appState: appState, scope: TaskScope.yearly),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final AppState appState;
  final TaskScope scope;

  const TaskList({
    super.key,
    required this.appState,
    required this.scope,
  });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final TextEditingController _controller = TextEditingController();

  List<Task> get _tasks =>
      widget.appState.tasks.where((t) => t.scope == widget.scope).toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _scopeTitle() {
    switch (widget.scope) {
      case TaskScope.daily:
        return 'Today\'s tasks';
      case TaskScope.weekly:
        return 'This week';
      case TaskScope.monthly:
        return 'This month';
      case TaskScope.yearly:
        return 'This year';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a task...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _scopeTitle(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _tasks.isEmpty
              ? const Center(child: Text('No tasks yet.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (v) {
                            setState(() {
                              widget.appState.toggleTask(task.id, v ?? false);
                            });
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              widget.appState.deleteTask(task.id);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.appState.addTask(text, widget.scope);
    });
    _controller.clear();
  }
}

/// ---------- CALENDAR PAGE (DAILY NOTES) ----------

class CalendarPage extends StatefulWidget {
  final AppState appState;

  const CalendarPage({super.key, required this.appState});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _controller = TextEditingController(
      text: widget.appState.getNoteForDate(_selectedDay!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
      _controller.text = widget.appState.getNoteForDate(selected);
    });
  }

  void _saveNote() {
    if (_selectedDay == null) return;
    widget.appState.setNoteForDate(_selectedDay!, _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null &&
                day.year == _selectedDay!.year &&
                day.month == _selectedDay!.month &&
                day.day == _selectedDay!.day,
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Daily note',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Write about your day...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save'),
                      onPressed: _saveNote,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- AVATAR PAGE (MOOD / SUCCESS / SOCIABILITY) ----------

class AvatarPage extends StatefulWidget {
  final AppState appState;

  const AvatarPage({super.key, required this.appState});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  @override
  Widget build(BuildContext context) {
    final todayMood = widget.appState.getMoodForDate(DateTime.now());
    final avg = todayMood?.average;

    String emoji;
    String status;

    if (avg == null) {
      emoji = '😐';
      status = 'No rating yet for today.';
    } else if (avg >= 7) {
      emoji = '😄';
      status = 'Great day!';
    } else if (avg >= 4) {
      emoji = '😕';
      status = 'Average day.';
    } else {
      emoji = '😢';
      status = 'Tough day.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your avatar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (avg != null) ...[
            const SizedBox(height: 4),
            Text(
              'Average: ${avg.toStringAsFixed(1)} / 10',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _showRateDialog,
            child: const Text('Rate today'),
          ),
          const SizedBox(height: 12),
          const Text(
            'You rate Success, Sociability and Mood\n(0–10) and your avatar changes.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showRateDialog() async {
    int success = 5;
    int sociability = 5;
    int mood = 5;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('Rate your day'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sliderRow(
                    label: 'Success',
                    value: success.toDouble(),
                    onChanged: (v) => setLocalState(() => success = v.round()),
                  ),
                  _sliderRow(
                    label: 'Sociability',
                    value: sociability.toDouble(),
                    onChanged: (v) =>
                        setLocalState(() => sociability = v.round()),
                  ),
                  _sliderRow(
                    label: 'Mood',
                    value: mood.toDouble(),
                    onChanged: (v) => setLocalState(() => mood = v.round()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FilledButton(
                child: const Text('Save'),
                onPressed: () {
                  widget.appState.setMoodForDate(
                    DateTime.now(),
                    success,
                    sociability,
                    mood,
                  );
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.round()}/10'),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
