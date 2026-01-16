import '../db/app_db.dart';
import 'utils.dart';
import 'session_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Stored only in-memory to show once (we also store in DB as hashed pass).
  String? _testEmail;
  String? _testPassword;

  String? get testEmail => _testEmail;
  String? get testPassword => _testPassword;

  Future<void> ensureTestUserOnFirstLaunch() async {
    final shown = await SessionService.instance.wasTestCredsShown();
    if (shown) return;

    // If there is already a user, we still create a new test user only once,
    // but you can change this behavior if you want.
    final email = randomEmail();
    final pass = randomPassword();
    final hash = hashPassword(pass);

    final now = DateTime.now().toIso8601String();

    final db = AppDb.instance.db;
    final id = await db.insert('users', {
      'email': email,
      'password_hash': hash,
      'created_at': now,
    });

    // Set default avatar for that user
    await db.insert('avatar_prefs', {
      'user_id': id,
      'hair': 0,
      'eyes': 0,
      'outfit': 0,
    });

    _testEmail = email;
    _testPassword = pass;
  }

  Future<int?> login(String email, String password) async {
    final db = AppDb.instance.db;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final stored = rows.first['password_hash'] as String;
    if (stored != hashPassword(password)) return null;

    final id = rows.first['id'] as int;
    await SessionService.instance.setUserId(id);
    return id;
  }

  Future<int?> signup(String email, String password) async {
    final db = AppDb.instance.db;
    final now = DateTime.now().toIso8601String();
    try {
      final id = await db.insert('users', {
        'email': email,
        'password_hash': hashPassword(password),
        'created_at': now,
      });

      await db.insert('avatar_prefs', {
        'user_id': id,
        'hair': 0,
        'eyes': 0,
        'outfit': 0,
      });
      await SessionService.instance.setUserId(id);
      return id;
    } catch (_) {
      return null; // email already exists etc.
    }
  }

  Future<void> logout() async {
    await SessionService.instance.setUserId(null);
  }
}
