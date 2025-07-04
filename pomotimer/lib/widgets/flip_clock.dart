import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class FlipClock extends StatefulWidget {
  final String minutes;
  final String seconds;
  final bool isBreak;

  const FlipClock({
    super.key,
    required this.minutes,
    required this.seconds,
    this.isBreak = false,
  });

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> with TickerProviderStateMixin {
  late AnimationController _minuteTensController;
  late AnimationController _minuteOnesController;
  late AnimationController _secondTensController;
  late AnimationController _secondOnesController;

  late Animation<double> _minuteTensAnimation;
  late Animation<double> _minuteOnesAnimation;
  late Animation<double> _secondTensAnimation;
  late Animation<double> _secondOnesAnimation;

  String _lastMinutes = '00';
  String _lastSeconds = '00';

  String _nextMinutesTens = '0';
  String _nextMinutesOnes = '0';
  String _nextSecondsTens = '0';
  String _nextSecondsOnes = '0';

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _minuteTensController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _minuteOnesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _secondTensController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _secondOnesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Setup animations
    _minuteTensAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _minuteTensController,
        curve: Curves.easeOutCubic,
      ),
    );

    _minuteOnesAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _minuteOnesController,
        curve: Curves.easeOutCubic,
      ),
    );

    _secondTensAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _secondTensController,
        curve: Curves.easeOutCubic,
      ),
    );

    _secondOnesAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _secondOnesController,
        curve: Curves.easeOutCubic,
      ),
    );

    _lastMinutes = widget.minutes;
    _lastSeconds = widget.seconds;

    _nextMinutesTens = widget.minutes[0];
    _nextMinutesOnes = widget.minutes[1];
    _nextSecondsTens = widget.seconds[0];
    _nextSecondsOnes = widget.seconds[1];
  }

  @override
  void dispose() {
    _minuteTensController.dispose();
    _minuteOnesController.dispose();
    _secondTensController.dispose();
    _secondOnesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlipClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only flip if the value has changed
    if (widget.minutes[0] != _lastMinutes[0]) {
      _nextMinutesTens = widget.minutes[0];
      _minuteTensController.reset();
      _minuteTensController.forward();
    }

    if (widget.minutes[1] != _lastMinutes[1]) {
      _nextMinutesOnes = widget.minutes[1];
      _minuteOnesController.reset();
      _minuteOnesController.forward();
    }

    if (widget.seconds[0] != _lastSeconds[0]) {
      _nextSecondsTens = widget.seconds[0];
      _secondTensController.reset();
      _secondTensController.forward();
    }

    if (widget.seconds[1] != _lastSeconds[1]) {
      _nextSecondsOnes = widget.seconds[1];
      _secondOnesController.reset();
      _secondOnesController.forward();
    }

    _lastMinutes = widget.minutes;
    _lastSeconds = widget.seconds;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Make cards larger and take more width of the screen
    // Increase sizes for both landscape and portrait modes
    final digitSize = isLandscape 
        ? size.height * 0.5 // Maximize in landscape by using 50% of screen height
        : size.width * 0.25; // Larger cards in portrait mode (25% of screen width)
    
    // Calculate height with proper ratio - make landscape more rectangular
    final digitHeight = isLandscape 
        ? size.height * 0.75 // 75% of screen height in landscape (more rectangular)
        : size.width * 0.375; // 1.5x width ratio in portrait
    
    // Use FittedBox to ensure the clock can take as much width as possible
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 10 : 20, // Added margin in portrait mode (increased from 0 to 20)
          vertical: isLandscape ? 0 : 10 // Reduced padding in portrait mode
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedDigit(
              _lastMinutes[0],
              _nextMinutesTens,
              _minuteTensAnimation,
              digitSize,
              digitHeight,
            ),
            _buildAnimatedDigit(
              _lastMinutes[1],
              _nextMinutesOnes,
              _minuteOnesAnimation,
              digitSize,
              digitHeight,
            ),
            _buildSeparator(digitSize, digitHeight),
            _buildAnimatedDigit(
              _lastSeconds[0],
              _nextSecondsTens,
              _secondTensAnimation,
              digitSize,
              digitHeight,
            ),
            _buildAnimatedDigit(
              _lastSeconds[1],
              _nextSecondsOnes,
              _secondOnesAnimation,
              digitSize,
              digitHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDigit(
    String currentDigit,
    String nextDigit,
    Animation<double> animation,
    double size,
    double digitHeight,
  ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? size * 0.015 : size * 0.02, // Slightly more spacing in portrait mode
      ),
      child: SizedBox(
        width: size,
        height: digitHeight,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final value = animation.value;
            final isHalfWay = value >= pi / 2;

            return Stack(
              children: [
                // Current Card
                Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(value),
                  child: _buildFullDigitCard(currentDigit, size, digitHeight),
                ),

                // Next Card (back side)
                if (value > 0)
                  Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(value - pi),
                    child: _buildFullDigitCard(nextDigit, size, digitHeight, isBack: true),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Builds a full card with a single digit
  Widget _buildFullDigitCard(String digit, double size, double digitHeight, {bool isBack = false}) {
    return Container(
      height: digitHeight,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(size * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: size * 0.01,
            spreadRadius: size * 0.005,
          ),
        ],
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom positioned text to maximize size
          Positioned.fill(
            child: Center(
              child: Text(
                digit,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: digitHeight * 0.85, // Using 85% of the card height for font size
                    fontWeight: FontWeight.w900, // Black weight
                    height: 1.0, // Ensure no extra line height
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(double size, double digitHeight) {
    return SizedBox(
      height: digitHeight,
      width: size * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size * 0.12,
            height: size * 0.12,
            margin: EdgeInsets.symmetric(vertical: digitHeight * 0.15),
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.12,
            height: size * 0.12,
            margin: EdgeInsets.symmetric(vertical: digitHeight * 0.15),
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
