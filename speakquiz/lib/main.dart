import 'package:flutter/material.dart';
import 'package:speakquiz/HomePage.dart';
import 'package:provider/provider.dart';
import 'package:speakquiz/quiz_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Homepage(),
      ),
    );
  }
}

