import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/auth_service.dart';
import 'auth_page.dart';
import 'profile_page.dart';
import 'focus_page.dart';
import 'calendar_page.dart';
import 'todos_page.dart';
import 'settings_page.dart';
import 'mood_page.dart';
import 'dart:io';

Future<void> _maybeShowTestCreds() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return;
}

enum HubTarget { profile, focus, calendar, todos, settings, mood }

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTestCreds());
  }

  Future<void> _maybeShowTestCreds() async {
    final shown = await SessionService.instance.wasTestCredsShown();
    if (shown) return;

    final email = AuthService.instance.testEmail;
    final pass = AuthService.instance.testPassword;
    if (email == null || pass == null) {
      await SessionService.instance.markTestCredsShown();
      return;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test user created (shown once)'),
        content: SelectableText('Email: $email\nPassword: $pass'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    await SessionService.instance.markTestCredsShown();
  }

  Future<void> _openTarget(HubTarget target) async {
    final userId = await SessionService.instance.getUserId();
    if (userId == null) {
      if (!mounted) return;
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => AuthPage(redirectTo: target)),
      );
      if (ok != true) return; // still not logged in
    }

    if (!mounted) return;
    switch (target) {
      case HubTarget.profile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      case HubTarget.focus:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FocusPage()),
        );
        break;
      case HubTarget.calendar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarPage()),
        );
        break;
      case HubTarget.todos:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodosPage()),
        );
        break;
      case HubTarget.settings:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;
      case HubTarget.mood:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MoodPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Colors.white;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 340,
            height: 340,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // center avatar
                _circleButton(
                  size: 140,
                  icon: Icons.person,
                  onTap: () => _openTarget(HubTarget.profile),
                ),

                // top ?
                Positioned(
                  top: 10,
                  child: _circleButton(
                    size: 64,
                    icon: Icons.help_outline,
                    onTap: () => _openTarget(HubTarget.focus),
                  ),
                ),

                // left calendar
                Positioned(
                  left: 10,
                  child: _circleButton(
                    size: 64,
                    icon: Icons.calendar_month,
                    onTap: () => _openTarget(HubTarget.calendar),
                  ),
                ),

                // right timer
                Positioned(
                  right: 10,
                  child: _circleButton(
                    size: 64,
                    icon: Icons.timer_outlined,
                    onTap: () => _openTarget(HubTarget.todos),
                  ),
                ),

                // bottom-left settings
                Positioned(
                  bottom: 10,
                  left: 60,
                  child: _circleButton(
                    size: 64,
                    icon: Icons.settings,
                    onTap: () => _openTarget(HubTarget.settings),
                  ),
                ),

                // bottom-right mood
                Positioned(
                  bottom: 10,
                  right: 60,
                  child: _circleButton(
                    size: 64,
                    icon: Icons.emoji_emotions_outlined,
                    onTap: () => _openTarget(HubTarget.mood),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required double size,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E4FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size * 0.45, color: Colors.black87),
      ),
    );
  }
}
