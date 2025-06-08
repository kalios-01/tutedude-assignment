import 'package:flutter/material.dart';

import 'MyHomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FFC2),
          brightness: Brightness.dark,
          primary: const Color(0xFF00FFC2),
          onPrimary: const Color(0xFF0A0A0A),
          secondary: const Color(0xFFEE00FF),
          onSecondary: const Color(0xFF0A0A0A),
          tertiary: const Color(0xFF00BFFF),
          onTertiary: const Color(0xFF0A0A0A),
          background: const Color(0xFF0A0A0A),
          onBackground: const Color(0xFFE0E0E0),
          surface: const Color(0xFF1C1C1C),
          onSurface: const Color(0xFFE0E0E0),
          surfaceVariant: const Color(0xFF2F2F2F),
          onSurfaceVariant: const Color(0xFFE0E0E0),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}