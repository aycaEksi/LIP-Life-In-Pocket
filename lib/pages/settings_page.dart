import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            await AuthService.instance.logout();
            if (context.mounted) {
              Navigator.pop(context); // back to hub (logged out)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
            }
          },
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
