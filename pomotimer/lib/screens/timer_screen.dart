import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';
import '../services/session_history_service.dart';
import '../services/notification_service.dart';
import '../widgets/flip_clock.dart';
import 'settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  bool _hasStartedOnce = false;
  bool _showDebugButton = false; // Change this from true to false to hide debug button
  Timer? _notificationCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set system UI for edge-to-edge display using a platform-compatible approach
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    
    // Only set overlay styles on iOS to avoid deprecated APIs on Android
    if (!Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ));
    }

    // Set portrait as the default orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Show debug info on startup
    _showDebugInfo();

    // Listen to timer status changes
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<TimerProvider>(context, listen: false);
      provider.addListener(_handleTimerStatusChanged);

      // Also listen for run/pause events to track if timer has started
      provider.addListener(() {
        if (provider.status == TimerStatus.running) {
          _hasStartedOnce = true;
        }
      });
      
      // Start a timer to periodically check notification status
      _startNotificationCheckTimer();
    });
  }

  void _showDebugInfo() {
    print("\n=== APP STARTUP DEBUG INFO ===");
    print("Displaying debug info for session history");
    SessionHistoryService.debugPrintAllData();
    print("===============================\n");
  }

  void _debugFunction() {
    print("\n=== DEBUG BUTTON PRESSED ===");
    // Print all session history
    SessionHistoryService.debugPrintAllData();

    // Force save current sessions
    final provider = Provider.of<TimerProvider>(context, listen: false);
    provider.debugSaveAndLoad();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Debug info printed to console. Check session data in logs.',
        ),
        duration: Duration(seconds: 3),
      ),
    );

    print("===========================\n");
  }

  void _startNotificationCheckTimer() {
    // Cancel existing timer if it's running
    _notificationCheckTimer?.cancel();
    
    // Check notification status every 10 seconds
    _notificationCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      // Only check if we're not disposed
      if (mounted) {
        final provider = Provider.of<TimerProvider>(context, listen: false);
        // Only check for running and break time status, not paused
        if (provider.status == TimerStatus.running || 
            provider.status == TimerStatus.breakTime) {
          // Verify the notification is running correctly
          NotificationService().checkStatus(provider);
        } else if (provider.status == TimerStatus.paused) {
          // Make sure notifications are stopped for paused timers
          NotificationService().stopTimerNotification();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (!mounted) return;
    
    final provider = Provider.of<TimerProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // App is in background or being closed
      print("App going to background, checking timer status");
      
      // Handle iOS differently using the dedicated lifecycle handler
      if (Platform.isIOS) {
        // Only handle lifecycle for iOS, don't call checkStatus
        NotificationService().handleLifecycle(state, provider);
      }
      // For Android, continue with existing approach 
      else if (provider.status == TimerStatus.running || 
          provider.status == TimerStatus.breakTime) {
        print("Timer is active, checking notification status");
        NotificationService().checkStatus(provider);
      }
      
      // Stop the notification check timer when app is in background
      _notificationCheckTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground
      print("App returning to foreground");
      
      // Also call the lifecycle handler for iOS on resume
      if (Platform.isIOS) {
        NotificationService().handleLifecycle(state, provider);
      }
      
      // Restart the notification check timer
      _startNotificationCheckTimer();
    }
  }

  @override
  void dispose() {
    // Cancel notification check timer
    _notificationCheckTimer?.cancel();
    
    // Reset orientation
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Remove listener
    final provider = Provider.of<TimerProvider>(context, listen: false);
    provider.removeListener(_handleTimerStatusChanged);
    
    // Ensure notification is stopped when screen is disposed
    if (provider.status != TimerStatus.running && 
        provider.status != TimerStatus.breakTime && 
        provider.status != TimerStatus.paused) {
      NotificationService().stopTimerNotification();
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleTimerStatusChanged() {
    final provider = Provider.of<TimerProvider>(context, listen: false);

    // Don't switch to landscape mode if we're just viewing historical data
    if (provider.viewingHistoricalData) {
      return;
    }

    if (provider.status == TimerStatus.running ||
        provider.status == TimerStatus.breakTime ||
        provider.status == TimerStatus.paused ||
        provider.status == TimerStatus.completed) {
      // Set to landscape mode when timer is running, paused, or completed
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Use immersive sticky mode in landscape while preserving edge-to-edge display
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
    } else {
      // Keep current orientation when reset is pressed
      // Only switch to portrait when app first starts or explicitly requested
      if (!_hasStartedOnce) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        // Show status bar in portrait mode with edge-to-edge display
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
      }
    }
  }

  void _showSettingsModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
        
    // Set system UI based on orientation using methods compatible with Android 15
    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      
      // Only set overlay styles on iOS to avoid deprecated APIs on Android
      if (!Platform.isAndroid) {
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ));
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: null,
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final isBreak = timerProvider.status == TimerStatus.breakTime;
          final isRunning =
              timerProvider.status == TimerStatus.running || isBreak;
          final isCompleted = timerProvider.status == TimerStatus.completed;

          return GestureDetector(
            onLongPress: _showSettingsModal,
            child: Container(
              color: const Color(0xFF1A1A1A),
              width: double.infinity,
              height: double.infinity,
              child: SafeArea(
                child:
                    isLandscape
                        ? _buildLandscapeLayout(
                          timerProvider,
                          isBreak,
                          isRunning,
                          isCompleted,
                        )
                        : _buildPortraitLayout(
                          timerProvider,
                          isBreak,
                          isRunning,
                          isCompleted,
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandscapeLayout(
    TimerProvider timerProvider,
    bool isBreak,
    bool isRunning,
    bool isCompleted,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: FlipClock(
                minutes: timerProvider.timeDisplayMinutes,
                seconds: timerProvider.timeDisplaySeconds,
                isBreak: isBreak,
              ),
            ),
          ),
        ),
        // Button container now below the flip clock
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exit fullscreen button now in the button box
                  ElevatedButton(
                    onPressed: () {
                      // Exit fullscreen mode
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);

                      // Optional: Also pause the timer when exiting fullscreen
                      if (isRunning) {
                        timerProvider.pauseTimer();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black54,
                    ),
                    child: const Icon(Icons.fullscreen_exit, size: 18),
                  ),
                  const SizedBox(width: 10),
                  if (!isRunning && !isCompleted) ...[
                    ElevatedButton(
                      onPressed: timerProvider.startTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.greenAccent,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(Icons.play_arrow, size: 22),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: timerProvider.resetTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(Icons.refresh, size: 18),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: timerProvider.addOneMinute,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Text(
                        '+1',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (isCompleted) ...[
                    ElevatedButton(
                      onPressed: timerProvider.startTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.greenAccent,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(Icons.play_arrow, size: 22),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: timerProvider.resetTimer,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(Icons.refresh, size: 18),
                    ),
                  ],
                  if (isRunning) ...[
                    ElevatedButton(
                      onPressed: () {
                        timerProvider.pauseTimer();
                        // Explicitly stop the notification check timer to prevent auto-restart
                        _notificationCheckTimer?.cancel();
                        // Restart it with a delay to ensure it doesn't interfere with pausing
                        Future.delayed(const Duration(seconds: 1), () {
                          _startNotificationCheckTimer();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black54,
                      ),
                      child: const Icon(Icons.pause, size: 22),
                    ),
                    if (!isBreak) ...[
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: timerProvider.addOneMinute,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black54,
                        ),
                        child: const Text(
                          '+1',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
    TimerProvider timerProvider,
    bool isBreak,
    bool isRunning,
    bool isCompleted,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // App title in portrait mode only
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "POMO-TIMER",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: FlipClock(
                  minutes: timerProvider.timeDisplayMinutes,
                  seconds: timerProvider.timeDisplaySeconds,
                  isBreak: isBreak,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isCompleted ? 'BREAK TIME' : (isBreak ? 'BREAK' : 'FOCUS'),
              style: TextStyle(
                fontSize: 16,
                color:
                    isCompleted || isBreak
                        ? Colors.greenAccent
                        : Colors.white70,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      isCompleted
                          ? timerProvider.startTimer
                          : (isRunning
                              ? () {
                                  timerProvider.pauseTimer();
                                  // Explicitly stop the notification check timer to prevent auto-restart
                                  _notificationCheckTimer?.cancel();
                                  // Restart it with a delay to ensure it doesn't interfere with pausing
                                  Future.delayed(const Duration(seconds: 1), () {
                                    _startNotificationCheckTimer();
                                  });
                                }
                              : timerProvider.startTimer),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white10,
                    foregroundColor:
                        isCompleted ? Colors.greenAccent : Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black54,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.play_arrow
                        : (isRunning ? Icons.pause : Icons.play_arrow),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: timerProvider.resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black54,
                  ),
                  child: const Icon(Icons.refresh, size: 32),
                ),
                if (timerProvider.status == TimerStatus.running) ...[
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: timerProvider.skipToBreak,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.black54,
                    ),
                    child: const Icon(Icons.skip_next, size: 32),
                  ),
                ],
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _showSettingsModal,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black54,
                  ),
                  child: const Icon(Icons.settings, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Statistics Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add history banner if viewing historical data
                  if (timerProvider.viewingHistoricalData)
                    _buildHistoryBanner(timerProvider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timerProvider.viewingHistoricalData
                            ? '${timerProvider.selectedDate.day} ${_getMonthName(timerProvider.selectedDate.month)}'
                            : 'Today',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        timerProvider.totalTimeToday,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child:
                        timerProvider.todaySessions.isEmpty
                            ? const SizedBox(
                              height: 80,
                              child: Center(
                                child: Text(
                                  'No sessions completed yet',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            : SizedBox(
                              height: 90,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: List.generate(
                                    timerProvider.todaySessions.length,
                                    (index) {
                                      final reversedIndex =
                                          timerProvider.todaySessions.length -
                                          1 -
                                          index;
                                      final duration =
                                          timerProvider
                                              .todaySessions[reversedIndex] ~/
                                          60;
                                      final durationText =
                                          timerProvider.formatMinutes(duration);
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              index !=
                                                      timerProvider
                                                              .todaySessions
                                                              .length -
                                                          1
                                                  ? 15
                                                  : 0,
                                        ),
                                        child: _buildSessionInfo(
                                          'Session ${reversedIndex + 1}',
                                          durationText,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 20),
                  // Month calendar view
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMonthYearLabel(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildMonthCalendar(timerProvider),
                      ],
                    ),
                  ),
                  // Return to current day button
                  _buildReturnToTodayButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // History banner to show when viewing historical data
  Widget _buildHistoryBanner(TimerProvider timerProvider) {
    final dateFormat =
        '${timerProvider.selectedDate.day} ${_getMonthName(timerProvider.selectedDate.month)} ${timerProvider.selectedDate.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Viewing history: $dateFormat',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: () => timerProvider.returnToCurrentDay(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Return to Today'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(String label, String duration) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            duration,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Month calendar view
  Widget _buildMonthCalendar(TimerProvider timerProvider) {
    final now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Calculate days in month
    final int daysInMonth = lastDayOfMonth.day;

    // Determine the starting weekday of the month (0 = Monday, 6 = Sunday)
    int startWeekday = firstDayOfMonth.weekday - 1; // Convert to 0-based
    if (startWeekday < 0) startWeekday = 6; // Handle Sunday as 6

    // Create grid for days
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => SizedBox(
                      width: 28,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate(
          (daysInMonth + startWeekday + 6) ~/ 7, // Number of rows needed
          (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex + 1 - startWeekday;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    // Empty cell
                    return const SizedBox(width: 28, height: 36);
                  }

                  // Create date for this cell
                  final day = DateTime(now.year, now.month, dayNumber);
                  final dayKey = '${day.year}-${day.month}-${day.day}';
                  final isToday = _isSameDay(day, now);
                  final isPast = day.isBefore(now) && !isToday;
                  final isFuture = day.isAfter(now);
                  final duration = timerProvider.getWeekStatus()[dayKey] ?? 0;
                  final hasSession = duration > 0;
                  final isSelected = _isSameDay(
                    day,
                    timerProvider.selectedDate,
                  );

                  // Format minutes for display using the helper method
                  final String durationText = hasSession ? timerProvider.formatMinutes(duration) : '';

                  return _buildCalendarDay(
                    day: day,
                    dayNumber: dayNumber,
                    isToday: isToday,
                    isPast: isPast,
                    isFuture: isFuture,
                    hasSession: hasSession,
                    duration: duration,
                    isSelected: isSelected,
                    durationText: durationText,
                    timerProvider: timerProvider,
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarDay({
    required DateTime day,
    required int dayNumber,
    required bool isToday,
    required bool isPast,
    required bool isFuture,
    required bool hasSession,
    required int duration,
    required bool isSelected,
    required String durationText,
    required TimerProvider timerProvider,
  }) {
    final textColor =
        isToday
            ? Colors.greenAccent
            : (hasSession && isPast ? Colors.greenAccent : Colors.white70);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {
          // Only allow tapping on past days or today
          if (isPast || isToday) {
            // Same loading logic as before
            if (isPast) {
              // Force portrait mode when viewing historical data
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);

              // Load the sessions for this day
              timerProvider.loadSessionsForDate(day);
            } else if (isToday) {
              // For today, return to current day's sessions
              timerProvider.returnToCurrentDay();

              // Check timer status for orientation
              if (timerProvider.status == TimerStatus.running ||
                  timerProvider.status == TimerStatus.breakTime ||
                  timerProvider.status == TimerStatus.paused ||
                  timerProvider.status == TimerStatus.completed) {
                // Allow both orientations
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              } else {
                // Force portrait mode only
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
            }
          }
        },
        child: Container(
          width: 28,
          height: 36, // Increased height to accommodate duration text
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isToday
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1))
                    : (isToday
                        ? Colors.greenAccent.withOpacity(0.1)
                        : Colors.transparent),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  isSelected
                      ? (isToday ? Colors.greenAccent : Colors.white60)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                dayNumber.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(height: 1),
              // Duration text for days with sessions or red indicator for missed days
              if (hasSession)
                Text(
                  durationText,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 8, // Small font size for the calendar
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (isPast)
                Container(
                  height: 4,
                  width: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthYearLabel() {
    final now = DateTime.now();
    return '${_getMonthName(now.month)} ${now.year}';
  }

  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Return to current day button
  Widget _buildReturnToTodayButton() {
    return Visibility(
      visible:
          Provider.of<TimerProvider>(
            context,
            listen: false,
          ).viewingHistoricalData,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text('Return to Today'),
          onPressed: () {
            final timerProvider = Provider.of<TimerProvider>(
              context,
              listen: false,
            );
            timerProvider.returnToCurrentDay();

            // Check if timer is in a state that should be in landscape
            if (timerProvider.status == TimerStatus.running ||
                timerProvider.status == TimerStatus.breakTime ||
                timerProvider.status == TimerStatus.paused ||
                timerProvider.status == TimerStatus.completed) {
              // Allow both portrait and landscape
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
              // Set immersive mode for running timer (likely to be in landscape)
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              print("Restored all orientation options for running timer");
            } else {
              // Force portrait mode only
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              // Show status bar in portrait mode
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              print("Keeping portrait mode for non-running timer");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
