import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'app_local.db');

    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, _) async {
        await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          created_at TEXT NOT NULL
        );
      ''');

        await db.execute('''
        CREATE TABLE day_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          date TEXT NOT NULL, -- YYYY-MM-DD
          note TEXT,
          photo1_path TEXT,
          photo2_path TEXT,
          UNIQUE(user_id, date)
        );
      ''');

        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          period TEXT NOT NULL, -- daily/weekly/monthly/yearly
          title TEXT NOT NULL,
          done INTEGER NOT NULL DEFAULT 0,
          due_date TEXT -- nullable ISO date
        );
      ''');

        await db.execute('''
        CREATE TABLE capsules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          note TEXT NOT NULL,
          unlock_at TEXT NOT NULL, -- ISO datetime
          created_at TEXT NOT NULL
        );
      ''');

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

        await db.execute('''
        CREATE TABLE IF NOT EXISTS focus_daily (
          user_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          hydration_count INTEGER NOT NULL DEFAULT 0,
          movement_count INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY (user_id, date)
        )
      ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS personal_reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          text TEXT NOT NULL,
          done INTEGER NOT NULL DEFAULT 0
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Version 1 -> 2: add focus_daily
          await db.execute('''
          CREATE TABLE IF NOT EXISTS focus_daily (
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            hydration_count INTEGER NOT NULL DEFAULT 0,
            movement_count INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (user_id, date)
          )
        ''');
        }
        if (oldVersion < 3) {
          // Version 2 -> 3: add personal_reminders
          await db.execute('''
          CREATE TABLE IF NOT EXISTS personal_reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            text TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
        }
      },
    );
  }

  Database get db {
    final d = _db;
    if (d == null) throw StateError('DB not initialized');
    return d;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) await db.close();
  }
}
