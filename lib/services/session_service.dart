import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _kUserId = 'session_user_id';
  static const _kTestShown = 'test_creds_shown_once';

  Future<int?> getUserId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kUserId);
  }

  Future<void> setUserId(int? id) async {
    final sp = await SharedPreferences.getInstance();
    if (id == null) {
      await sp.remove(_kUserId);
    } else {
      await sp.setInt(_kUserId, id);
    }
  }

  Future<bool> wasTestCredsShown() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kTestShown) ?? false;
  }

  Future<void> markTestCredsShown() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kTestShown, true);
  }
}
