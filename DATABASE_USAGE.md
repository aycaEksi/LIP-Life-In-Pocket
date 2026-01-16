# Database Kullanım Örnekleri

## 1. User Repository

```dart
import 'package:lip_app/repositories/user_repository.dart';
import 'package:lip_app/models/user.dart';

final userRepo = UserRepository();

// Kullanıcı kayıt etme
final newUser = User(
  email: 'test@example.com',
  password: 'password123',
);
int userId = await userRepo.createUser(newUser);

// Login işlemi
User? user = await userRepo.login('test@example.com', 'password123');

// Kullanıcı bilgilerini getirmek için fonk
User? user = await userRepo.getUserById(userId);
```

## 2. Avatar Repository

```dart
import 'package:lip_app/repositories/avatar_repository.dart';
import 'package:lip_app/models/avatar.dart';

final avatarRepo = AvatarRepository();

// Avatar kaydetme fonk
final avatar = Avatar(
  userId: currentUserId,
  avatarPath: 'assets/avatars/avatar1.png',
);
await avatarRepo.createAvatar(avatar);

// Kullanıcının son avatarını getirme fonk
Avatar? latestAvatar = await avatarRepo.getLatestAvatarByUserId(currentUserId);
```

## 3. Mood Repository

```dart
import 'package:lip_app/repositories/mood_repository.dart';
import 'package:lip_app/models/mood.dart';

final moodRepo = MoodRepository();

// mod kaydetme fonk
final mood = Mood(
  userId: currentUserId,
  energy: 8,
  happiness: 7,
  stress: 3,
);
await moodRepo.createMood(mood);

// mod getirme fonk
Mood? todayMood = await moodRepo.getTodayMoodByUserId(currentUserId);
```

## 4. Journal Repository

```dart
import 'package:lip_app/repositories/journal_repository.dart';
import 'package:lip_app/models/journal.dart';

final journalRepo = JournalRepository();

// Günlük ekleme
final journal = Journal(
  userId: currentUserId,
  moodId: moodId,
  title: 'Güzel bir gün',
  content: 'Bugün çok güzeldi...',
  entryDate: DateTime.now().toIso8601String().split('T')[0],
);
await journalRepo.createJournal(journal);

// Kullanıcının tüm günlüklerini getirir
List<Journal> journals = await journalRepo.getJournalsByUserId(currentUserId);
```

## 5. Task Repository

```dart
import 'package:lip_app/repositories/task_repository.dart';
import 'package:lip_app/models/task.dart';

final taskRepo = TaskRepository();

// Görev ekleme
final task = Task(
  userId: currentUserId,
  title: 'Spor yap',
  description: 'Sabah koşusu',
  taskType: 'daily',
  dueDate: DateTime.now().toIso8601String().split('T')[0],
);
await taskRepo.createTask(task);

// Günlük görevleri getirir
List<Task> dailyTasks = await taskRepo.getTasksByType(currentUserId, 'daily');

// Görevi tamamla
await taskRepo.toggleTaskCompletion(taskId, true);
```

## Ekranlarda Kullanım Örneği

```dart
class HomeScreen extends StatefulWidget {
  final int currentUserId;
  
  const HomeScreen({required this.currentUserId, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  List<Task> _todayTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    final tasks = await _taskRepo.getTodayTasks(widget.currentUserId);
    setState(() {
      _todayTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _todayTasks.length,
        itemBuilder: (context, index) {
          final task = _todayTasks[index];
          return ListTile(
            title: Text(task.title),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) async {
                await _taskRepo.toggleTaskCompletion(task.id!, value ?? false);
                _loadTodayTasks();
              },
            ),
          );
        },
      ),
    );
  }
}
```
