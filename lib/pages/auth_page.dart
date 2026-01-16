import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'hub_page.dart';

class AuthPage extends StatefulWidget {
  final HubTarget redirectTo;
  const AuthPage({super.key, required this.redirectTo});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  String? _err;

  Future<void> _submit() async {
    setState(() => _err = null);
    final email = _email.text.trim();
    final pass = _pass.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _err = 'Fill email + password');
      return;
    }

    final id = _isLogin
        ? await AuthService.instance.login(email, pass)
        : await AuthService.instance.signup(email, pass);

    if (id == null) {
      setState(
        () => _err = _isLogin
            ? 'Wrong credentials'
            : 'Signup failed (email may exist)',
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, true); // success; Hub will open target
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Log in' : 'Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (_err != null)
              Text(_err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Log in' : 'Create account'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? 'Need an account? Sign up'
                    : 'Have an account? Log in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
