import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _focusTimeController = TextEditingController();
  final _breakTimeController = TextEditingController();
  String? _selectedSoundPath;
  bool _useCustomSound = false;

  @override
  void initState() {
    super.initState();
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    _focusTimeController.text = (timerProvider.focusTime ~/ 60).toString();
    _breakTimeController.text = (timerProvider.breakTime ~/ 60).toString();
    _selectedSoundPath = timerProvider.customAlarmPath;
    _useCustomSound = timerProvider.useCustomAlarm;
  }

  @override
  void dispose() {
    _focusTimeController.dispose();
    _breakTimeController.dispose();
    super.dispose();
  }
  
  Future<void> _pickAudioFile() async {
    try {
      print("FILE PICKER: Starting file picker on platform: ${Platform.operatingSystem}");
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        String path = result.files.first.path!;
        print("FILE PICKER: Selected file path: $path");
        print("FILE PICKER: File name: ${result.files.first.name}");
        print("FILE PICKER: File size: ${result.files.first.size} bytes");
        
        if (Platform.isAndroid) {
          final isContentUri = path.startsWith('content://');
          print("FILE PICKER: Is Android content URI: $isContentUri");
        }
        
        // Verify the file exists
        final file = File(path);
        final exists = await file.exists();
        print("FILE PICKER: Selected file exists: $exists");
        
        if (exists) {
          try {
            // Verify file is readable
            final fileSize = await file.length();
            print("FILE PICKER: File size from File API: $fileSize bytes");
            
            if (fileSize > 0) {
              try {
                final bytes = await file.readAsBytes();
                print("FILE PICKER: Successfully read ${bytes.length} bytes");
                
                setState(() {
                  _selectedSoundPath = path;
                  _useCustomSound = true;
                });
                
                // Show a success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected sound: ${result.files.first.name}')),
                  );
                }
              } catch (e) {
                print("FILE PICKER: Error reading file: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error reading sound file: $e')),
                );
              }
            } else {
              print("FILE PICKER: File exists but has zero size");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected file has zero size')),
              );
            }
          } catch (e) {
            print("FILE PICKER: Error checking file: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error checking sound file: $e')),
            );
          }
        } else {
          print("FILE PICKER: File does not exist despite being selected");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected file does not exist')),
          );
        }
      } else {
        print("FILE PICKER: No file selected or selection cancelled");
      }
    } catch (e) {
      print("FILE PICKER: Error picking file: $e");
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting sound: $e')),
        );
      }
    }
  }
  
  String _getFileName(String? path) {
    if (path == null) return 'Default Alarm';
    return path.split('/').last;
  }

  Future<void> _testSound() async {
    final soundPath = _selectedSoundPath;
    if (soundPath == null || soundPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No custom sound selected')),
      );
      return;
    }

    print('TEST SOUND: Attempting to play sound from path: $soundPath');
    print('TEST SOUND: Platform: ${Platform.operatingSystem}');
    
    try {
      final file = File(soundPath);
      final exists = await file.exists();
      print('TEST SOUND: File exists: $exists');
      print('TEST SOUND: File path type: ${file.runtimeType}');
      print('TEST SOUND: Absolute path: ${file.absolute.path}');
      
      // For Android, check content URI format
      if (Platform.isAndroid) {
        final isContentUri = soundPath.startsWith('content://');
        print('TEST SOUND: Is content URI: $isContentUri');
        
        if (isContentUri) {
          print('TEST SOUND: Using content URI format on Android');
        } else {
          print('TEST SOUND: Using file path format on Android');
        }
      }
      
      if (!exists) {
        print('TEST SOUND: File does not exist!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sound file not found: $soundPath')),
        );
        return;
      }
      
      final fileSize = await file.length();
      print('TEST SOUND: File size: $fileSize bytes');
      
      if (fileSize <= 0) {
        print('TEST SOUND: File exists but has zero size');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sound file is empty')),
        );
        return;
      }
      
      try {
        final bytes = await file.readAsBytes();
        print('TEST SOUND: File is readable, read ${bytes.length} bytes');
      } catch (e) {
        print('TEST SOUND: Error reading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot read sound file: $e')),
        );
        return;
      }

      print('TEST SOUND: Creating AudioPlayer instance');
      final player = AudioPlayer();
      
      // Debug current state
      print('TEST SOUND: Initial player state: ${player.state}');
      
      print('TEST SOUND: Setting volume to 1.0');
      await player.setVolume(1.0);
      
      // Listen for player state changes
      player.onPlayerStateChanged.listen((state) {
        print('TEST SOUND: Player state changed to: $state');
      });
      
      player.onPositionChanged.listen((position) {
        print('TEST SOUND: Position changed: ${position.inMilliseconds}ms');
      });
      
      player.onPlayerComplete.listen((_) {
        print('TEST SOUND: Playback completed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sound played successfully')),
        );
      });

      print('TEST SOUND: Attempting to play file with DeviceFileSource');
      
      // Try with Source abstraction
      final source = DeviceFileSource(soundPath);
      print('TEST SOUND: Created DeviceFileSource: $source');
      
      try {
        await player.play(source);
        print('TEST SOUND: Play command sent successfully');
        
        // Check player state right after play command
        print('TEST SOUND: Player state immediately after play: ${player.state}');
        
        // Try with a fixed play time for debug
        await Future.delayed(const Duration(seconds: 3));
        print('TEST SOUND: Player state after 3 seconds: ${player.state}');
        
        // Force play a default sound using AssetSource to test if player works
        if (player.state != PlayerState.playing) {
          print('TEST SOUND: Player not playing after 3 seconds. Trying with asset sound...');
          await player.play(AssetSource('sounds/alarm.mp3'));
          print('TEST SOUND: Attempted to play default sound');
        }
      } catch (e) {
        print('TEST SOUND: Exception during play call: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start playback: $e')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing sound...')),
      );
    } catch (e) {
      print('TEST SOUND: Error playing sound: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play sound: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Timer Settings'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Focus Time (minutes)',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _focusTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter focus time in minutes',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!, width: 1.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Break Time (minutes)',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _breakTimeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter break time in minutes',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[800]!, width: 1.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Alarm sound settings
                const Text(
                  'Alarm Sound',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Toggle for using custom sound
                Row(
                  children: [
                    Switch(
                      value: _useCustomSound,
                      onChanged: (value) {
                        setState(() {
                          _useCustomSound = value;
                        });
                      },
                      activeColor: Colors.greenAccent,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _useCustomSound ? 'Using custom sound' : 'Using default sound',
                      style: TextStyle(
                        color: _useCustomSound ? Colors.greenAccent : Colors.white70,
                      ),
                    ),
                  ],
                ),
                
                // Only show custom sound info if toggle is on
                if (_useCustomSound) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Selected Sound:',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _getFileName(_selectedSoundPath),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _pickAudioFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[700],
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Choose'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Add a test sound button
                        if (_selectedSoundPath != null) ...[
                          ElevatedButton.icon(
                            onPressed: _testSound,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 45),
                            ),
                            icon: const Icon(Icons.volume_up),
                            label: const Text('Test Sound'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      int focusTime = int.tryParse(_focusTimeController.text) ?? 25;
                      int breakTime = int.tryParse(_breakTimeController.text) ?? 5;
                      
                      // Validate input (minimum 1 minute, maximum 120 minutes)
                      focusTime = focusTime.clamp(1, 120);
                      breakTime = breakTime.clamp(1, 30);
                      
                      timerProvider.setFocusTime(focusTime);
                      timerProvider.setBreakTime(breakTime);
                      
                      // Save custom alarm sound settings
                      print("SETTINGS SAVE: useCustomSound=$_useCustomSound, selectedPath=$_selectedSoundPath");
                      if (_useCustomSound && _selectedSoundPath != null) {
                        print("SETTINGS SAVE: Saving custom sound path");
                        // First save the path, which also sets useCustomAlarm to true internally
                        await timerProvider.setCustomAlarmPath(_selectedSoundPath!);
                        
                        // Explicitly toggle sound on
                        await timerProvider.toggleUseCustomAlarm(true);
                        print("SETTINGS SAVE: Custom sound toggled ON");
                      } else {
                        print("SETTINGS SAVE: Not using custom sound or path is null");
                        // Make sure to explicitly toggle off custom sound if switch is off
                        await timerProvider.toggleUseCustomAlarm(false);
                        print("SETTINGS SAVE: Custom sound toggled OFF");
                      }
                      
                      // Verify the settings were saved correctly
                      print("SETTINGS SAVE: Final provider state - path: ${timerProvider.customAlarmPath}, useCustom: ${timerProvider.useCustomAlarm}");
                      
                      // Force a save to make sure all settings are persisted
                      await timerProvider.saveSettings();
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings saved')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 