import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lip_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // Avatars table
    await db.execute('''
      CREATE TABLE avatars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        hair_style TEXT,
        hair_color TEXT,
        outfit TEXT,
        outfit_color TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Moods table
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        energy INTEGER,
        happiness INTEGER,
        stress INTEGER,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Journals table
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        mood_id INTEGER,
        title TEXT,
        content TEXT,
        entry_date TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (mood_id) REFERENCES moods(id)
      )
    ''');

    // Journal photos table
    await db.execute('''
      CREATE TABLE journal_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        journal_id INTEGER,
        photo_path TEXT,
        created_at TEXT,
        FOREIGN KEY (journal_id) REFERENCES journals(id)
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT,
        description TEXT,
        task_type TEXT,
        is_completed INTEGER,
        due_date TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
