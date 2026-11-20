import 'package:flutter/material.dart';

import '../models/user_role.dart';

const _studentAccount = (username: 'student', password: 'student123');
const _adminAccount = (username: 'admin', password: 'admin123');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<UserRole> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
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
    final role = switch (credentials) {
      _studentAccount => UserRole.student,
      _adminAccount => UserRole.admin,
      _ => null,
    };
    if (role == null) {
      setState(() => _loginError = 'Incorrect username or password.');
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onLogin(role);
  }

  void _clearLoginError(String value) {
    if (_loginError != null) setState(() => _loginError = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: const Icon(Icons.school_outlined, size: 30),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'School announcement board',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay up to date with your campus and department.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    Text('Log in', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onChanged: _clearLoginError,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your username.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _loginError,
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      autofillHints: const [AutofillHints.password],
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: _clearLoginError,
                      onFieldSubmitted: (_) => _logIn(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _logIn,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Card.filled(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Try a demo account'),
                            SizedBox(height: 8),
                            SelectableText('Student: student / student123'),
                            SizedBox(height: 4),
                            SelectableText('Admin: admin / admin123'),
                          ],
                        ),
                      ),
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
