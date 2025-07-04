import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../providers/timer_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Timer? _updateTimer;
  bool _isRunning = false;
  DateTime? _lastUpdated;
  DateTime? _lastCompletionNotified;
  String? _lastAppState;

  // Custom alarm sound settings
  String? _customAlarmPath;
  bool _useCustomAlarm = false;

  static const int timerNotificationId = 1;
  static const int completionNotificationId = 2;

  NotificationService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'timer_completion') {
          print('User tapped on completion notification.');
        }
      },
    );

    // Permissions
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidPlugin =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    // Load custom alarm settings
    await _loadCustomAlarmSettings();
  }

  // Load custom alarm settings from SharedPreferences
  Future<void> _loadCustomAlarmSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _customAlarmPath = prefs.getString('customAlarmPath');
    _useCustomAlarm = prefs.getBool('useCustomAlarm') ?? false;

    // Verify file still exists
    if (_customAlarmPath != null && _useCustomAlarm) {
      print("NotificationService: Loaded custom alarm path: $_customAlarmPath");
      try {
        final file = File(_customAlarmPath!);
        final exists = await file.exists();
        print("NotificationService: Loaded sound file exists: $exists");

        if (!exists) {
          print(
            "NotificationService: Custom sound file no longer exists, resetting to default",
          );
          _useCustomAlarm = false;
          // We don't save here as that's handled by the provider
        }
      } catch (e) {
        print("NotificationService: Error checking custom sound file: $e");
        _useCustomAlarm = false;
      }
    }
  }

  void checkStatus(TimerProvider provider) {
    if (provider.status == TimerStatus.running ||
        provider.status == TimerStatus.breakTime) {
      if (!_isRunning) {
        startTimerNotification(provider);
      } else if (_lastUpdated != null &&
          DateTime.now().difference(_lastUpdated!).inSeconds > 30) {
        restartNotification(provider);
      }
    } else if (provider.status != TimerStatus.paused) {
      stopTimerNotification();
    }
  }

  void startTimerNotification(TimerProvider provider) {
    if (_isRunning) return;

    _isRunning = true;
    _lastUpdated = DateTime.now();

    _showOngoingNotification(provider);

    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNotification(provider);
      _lastUpdated = DateTime.now();

      if (provider.status != TimerStatus.running &&
          provider.status != TimerStatus.breakTime &&
          provider.status != TimerStatus.paused) {
        stopTimerNotification();
      }
    });
  }

  void restartNotification(TimerProvider provider) {
    stopTimerNotification();
    Future.delayed(const Duration(milliseconds: 500), () {
      startTimerNotification(provider);
    });
  }

  void stopTimerNotification() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _isRunning = false;
    _lastUpdated = null;
    _plugin.cancel(timerNotificationId);
  }

  void handleLifecycle(AppLifecycleState state, TimerProvider provider) {
    if (Platform.isIOS) {
      String current = state.toString();
      print("iOS: State change from $_lastAppState → $current");

      if (_lastAppState == "AppLifecycleState.resumed" &&
          (current.contains("paused") || current.contains("inactive"))) {
        if (!_isRunning &&
            (provider.status == TimerStatus.running ||
                provider.status == TimerStatus.breakTime)) {
          print("iOS: Starting notification in background");
          startTimerNotification(provider);
        } else {
          print("iOS: Notification already running or not needed");
        }
      } else if (current.contains("resumed")) {
        print("iOS: Resumed - updating notification if needed");
        if (_isRunning &&
            (provider.status == TimerStatus.running ||
                provider.status == TimerStatus.breakTime)) {
          _updateNotification(provider);
        }
      }

      _lastAppState = current;
    }
  }

  Future<void> _showOngoingNotification(TimerProvider provider) async {
    final status = _getStatus(provider.status);
    final time =
        '${provider.timeDisplayMinutes}:${provider.timeDisplaySeconds}';

    const androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Ongoing timer countdown',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      playSound: false,
      showWhen: false,
      enableVibration: false,
      category: AndroidNotificationCategory.service,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    await _plugin.show(
      timerNotificationId,
      'Pomo-Timer - $status',
      time,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _updateNotification(TimerProvider provider) async {
    final status = _getStatus(provider.status);
    final time =
        '${provider.timeDisplayMinutes}:${provider.timeDisplaySeconds}';

    const androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Updated timer countdown',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      playSound: false,
      showWhen: false,
      enableVibration: false,
      category: AndroidNotificationCategory.service,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    await _plugin.show(
      timerNotificationId,
      'Pomo-Timer - $status',
      time,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> showCompletionNotification(bool isBreak, {bool playSound = true}) async {
    final now = DateTime.now();
    if (_lastCompletionNotified != null &&
        now.difference(_lastCompletionNotified!).inSeconds < 3) {
      return;
    }
    _lastCompletionNotified = now;
    
    // Reload custom alarm settings before showing notification
    await _loadCustomAlarmSettings();

    final title = isBreak ? 'Break Finished!' : 'Focus Completed!';
    final body = isBreak ? 'Back to work.' : 'Nice! Take a break.';
    
    // Create Android notification details based on custom sound settings
    AndroidNotificationDetails androidDetails;
    
    if (_useCustomAlarm && _customAlarmPath != null && playSound) {
      // Check if file exists
      final file = File(_customAlarmPath!);
      final exists = await file.exists();
      print("Notification file exists check: $exists");
      
      if (exists) {
        // Create a proper URI for Android sound
        final uriPath = "file://${_customAlarmPath!}";
        print("Using notification sound URI: $uriPath");
        
        androidDetails = AndroidNotificationDetails(
          'completion_channel',
          'Completion',
          channelDescription: 'Timer completed',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          sound: UriAndroidNotificationSound(uriPath),
        );
      } else {
        print("Custom notification sound file doesn't exist, using default");
        androidDetails = const AndroidNotificationDetails(
          'completion_channel',
          'Completion',
          channelDescription: 'Timer completed',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          sound: RawResourceAndroidNotificationSound('alarm'),
        );
      }
    } else {
      // Use default sound or no sound based on playSound flag
      androidDetails = AndroidNotificationDetails(
        'completion_channel',
        'Completion',
        channelDescription: 'Timer completed',
        importance: Importance.max,
        priority: Priority.max,
        playSound: playSound,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        sound: playSound ? const RawResourceAndroidNotificationSound('alarm') : null,
      );
    }
    
    // Create iOS notification details based on custom sound settings
    DarwinNotificationDetails iosDetails;
    
    if (_useCustomAlarm && _customAlarmPath != null && playSound) {
      // Check if file exists
      final file = File(_customAlarmPath!);
      final exists = await file.exists();
      
      if (exists) {
        // Extract just the filename for iOS
        final fileName = _customAlarmPath!.split('/').last;
        print("iOS notification using sound file: $fileName from $_customAlarmPath");
        
        iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: fileName,
        );
      } else {
        print("Custom notification sound file doesn't exist for iOS, using default");
        iosDetails = const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alarm.mp3',
        );
      }
    } else {
      iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        sound: playSound ? 'alarm.mp3' : null,
      );
    }

    try {
      await _plugin.show(
        completionNotificationId,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'timer_completion',
      );
      
      // Only play sound if playSound is true
      if (playSound) {
        _playSound();
      } else {
        print("NotificationService: Skipping sound playback as requested");
      }
    } catch (e) {
      print("Error showing completion: $e");
      // Only play sound if playSound is true
      if (playSound) {
        _playSound();
      }
    }
  }

  void _playSound() async {
    const defaultSoundAsset = 'sounds/alarm.mp3';
    bool soundPlayed = false;
    
    try {
      // Reload custom alarm settings before playing
      await _loadCustomAlarmSettings();
      
      final player = AudioPlayer();
      await player.setVolume(1.0);
      
      // First priority: Try custom sound if enabled and exists
      if (_useCustomAlarm && _customAlarmPath != null) {
        print("NotificationService: Checking custom alarm at: $_customAlarmPath");
        
        final file = File(_customAlarmPath!);
        final exists = await file.exists();
        print("NotificationService: File exists check: $exists");
        
        if (exists) {
          try {
            print("NotificationService: Playing custom sound");
            await player.play(DeviceFileSource(_customAlarmPath!));
            print("NotificationService: Custom alarm play initiated successfully");
            soundPlayed = true;
          } catch (e) {
            print("NotificationService: Failed to play custom alarm: $e");
            // Will fall through to default sound
          }
        } else {
          print("NotificationService: Custom sound file not found");
        }
      }
      
      // Second priority: Default sound if custom failed
      if (!soundPlayed) {
        print("NotificationService: Playing default alarm sound");
        await player.play(AssetSource(defaultSoundAsset));
      }
    } catch (e) {
      print("NotificationService: Alarm sound failed: $e");
    }
  }

  String _getStatus(TimerStatus status) {
    switch (status) {
      case TimerStatus.running:
        return 'Focus';
      case TimerStatus.breakTime:
        return 'Break';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.completed:
        return 'Completed';
      case TimerStatus.idle:
        return 'Ready';
      default:
        return 'Timer';
    }
  }
}
