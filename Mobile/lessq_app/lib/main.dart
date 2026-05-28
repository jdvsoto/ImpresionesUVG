import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LessQApp());
}

class LessQApp extends StatelessWidget {
  const LessQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LessQ',
      theme: AppTheme.theme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
