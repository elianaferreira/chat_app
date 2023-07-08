import 'package:flutter/material.dart';

final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0XFFFFC95F));

final theme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: colorScheme,
);

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      theme: theme,
      home: ...,
    );
  }
}
