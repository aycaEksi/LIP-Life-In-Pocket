import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = await SessionService.instance.getUserId();
    if (uid == null) return;
    final rows = await AppDb.instance.db.query(
      'users',
      where: 'id=?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isEmpty) return;
    setState(() => email = rows.first['email'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: email == null
            ? const Text('Loading...')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $email'),
                  const SizedBox(height: 8),
                  const Text('More profile stuff later...'),
                ],
              ),
      ),
    );
  }
}
