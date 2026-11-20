import 'package:flutter/material.dart';

import 'data/announcement_store.dart';
import 'models/user_role.dart';
import 'screens/announcements_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _store = AnnouncementStore();
  UserRole? _role;

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(seedColor: const Color(0xFF255D77));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Announcement Board',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: colors.surface,
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
      ),
      home: _role == null
          ? LoginScreen(onLogin: (role) => setState(() => _role = role))
          : AnnouncementsScreen(
              key: ValueKey(_role),
              store: _store,
              role: _role!,
              onLogout: () => setState(() => _role = null),
            ),
    );
  }
}
