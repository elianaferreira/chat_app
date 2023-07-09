import 'package:flutter/material.dart';

import 'package:chat_app/screens/auth.dart';

final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0XFFF2BE22));

final theme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: colorScheme,
);

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: theme,
      home: const AuthScreen(),
    );
  }
}
