import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/timer_provider.dart';
import 'screens/timer_screen.dart';
import 'services/notification_service.dart';
import 'services/session_history_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI for edge-to-edge display
  // Use different system UI settings based on platform version for Android 15 compatibility
  if (Platform.isAndroid) {
    // For Android, use a more compatible approach to avoid deprecated APIs
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  } else {
    // For iOS and other platforms, continue with the transparent overlay approach
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
  
  // Initialize Hive database
  print("Initializing Hive database...");
  await SessionHistoryService.init();
  print("Hive initialization complete!");
  // Initialize notification service
  print("Initializing notification service...");
  await NotificationService().initialize();
  print("Notification service initialized!");

  runApp(
    ChangeNotifierProvider(
      create: (context) => TimerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const TimerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
