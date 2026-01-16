import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String raw) {
  final bytes = utf8.encode(raw);
  return sha256.convert(bytes).toString();
}

String randomEmail() {
  final r = Random.secure();
  final n = List.generate(10, (_) => r.nextInt(10)).join();
  return 'test$n@app.local';
}

String randomPassword() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
  final r = Random.secure();
  return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
}

String todayYMD(DateTime dt) {
  final d = DateTime(dt.year, dt.month, dt.day);
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
