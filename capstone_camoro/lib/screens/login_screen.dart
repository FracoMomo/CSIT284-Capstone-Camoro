import 'package:flutter/material.dart';

import 'admin_placeholder_screen.dart';
import 'announcements_screen.dart';

const _studentAccount = (username: 'student', password: 'student123');
const _adminAccount = (username: 'admin', password: 'admin123');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _loginError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _logIn() {
    if (!_formKey.currentState!.validate()) return;

    final credentials = (
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
    final destination = switch (credentials) {
      _studentAccount => const AnnouncementsScreen(),
      _adminAccount => const AdminPlaceholderScreen(),
      _ => null,
    };

    if (destination == null) {
      setState(() => _loginError = 'Incorrect username or password.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => destination),
    );
  }

  void _clearLoginError(String value) {
    if (_loginError != null) setState(() => _loginError = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Demo accounts'),
                    Text(
                      'Student: ${_studentAccount.username} / '
                      '${_studentAccount.password}',
                    ),
                    Text(
                      'Admin: ${_adminAccount.username} / '
                      '${_adminAccount.password}',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next,
                      onChanged: _clearLoginError,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your username.'
                          : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _loginError,
                      ),
                      obscureText: true,
                      onChanged: _clearLoginError,
                      onFieldSubmitted: (_) => _logIn(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _logIn,
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
