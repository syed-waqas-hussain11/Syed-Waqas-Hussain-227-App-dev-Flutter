import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Blue -> deep-blue gradient for an elegant look
    const Color lightBlue = Color(0xFF6EC6FF);
    const Color deepBlue = Color(0xFF0D47A1);

    return MaterialApp(
      title: 'Mini Ludo - Dice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: deepBlue),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),
      home: Scaffold(
        // App bar with a contrasting rounded bar behind the title (blue)
        appBar: AppBar(
          backgroundColor: deepBlue,
          elevation: 6,
          centerTitle: true,
          toolbarHeight: 64,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
            child: Text(
              'Mini Ludo Game',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.12,
                fontSize: 18,
              ),
            ),
          ),
        ),

        // Blue gradient background for elegant contrast
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [lightBlue, deepBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(child: Center(child: DiceCard())),
        ),
      ),
    );
  }
}

class DiceCard extends StatefulWidget {
  const DiceCard({super.key});

  @override
  State<DiceCard> createState() => _DiceCardState();
}

class _DiceCardState extends State<DiceCard>
    with SingleTickerProviderStateMixin {
  int _dice = 1;
  bool _started = false; // initial Lets Play view
  bool _isRolling = false; // prevents overlapping rolls
  final Random _random = Random();

  late final AnimationController _controller;
  late final Animation<double> _rotation; // rotates the dice
  late final Animation<double> _shake; // horizontal shake

  @override
  void initState() {
    super.initState();
    // Controller drives both rotation and shake; duration will be set when rolling
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rotation = Tween<double>(
      begin: 0.0,
      end: pi * 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _shake = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 6.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 6.0,
          end: -6.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -6.0,
          end: 3.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 3.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // ensure controller resets for next roll
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Roll the dice with animation: randomize faces rapidly while animating
  Future<void> _rollDiceAnimated() async {
    if (_isRolling) return;
    _isRolling = true;

    const int animationMs = 700;
    const int changes = 10;
    final int interval = (animationMs / changes).floor();

    // Start animation
    _controller.duration = const Duration(milliseconds: animationMs);
    _controller.forward(from: 0);

    // Rapidly change faces during the animation
    int ticks = 0;
    Timer.periodic(Duration(milliseconds: interval), (Timer t) {
      setState(() {
        _dice = _random.nextInt(6) + 1;
      });
      ticks++;
      if (ticks >= changes) {
        t.cancel();
      }
    });

    // Wait for animation to finish
    await Future.delayed(Duration(milliseconds: animationMs));

    // Ensure final face is randomized one last time
    setState(() {
      _dice = _random.nextInt(6) + 1;
    });

    _isRolling = false;
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final double maxWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (maxWidth * 0.86).clamp(300.0, 460.0);
    final double diceSize = (cardWidth * 0.44).clamp(110.0, 220.0);

    return Card(
      elevation: 18,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _started
              ? _buildDiceView(context, diceSize)
              : _buildStartView(context),
        ),
      ),
    );
  }

  Widget _buildStartView(BuildContext context) {
    return SizedBox(
      key: const ValueKey('start'),
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Let's Play!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to begin and roll the dice',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => setState(() => _started = true),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text("Let's Play"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1), // deep blue
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceView(BuildContext context, double diceSize) {
    // Updated to load images from the project's `images/` folder (root).
    // If your files are named "1.png" .. "6.png" inside the top-level images/ folder,
    // this will find them. If your assets are under assets/images/img1.png, change accordingly.
    final String imagePath = 'images/$_dice.png';

    return SizedBox(
      key: const ValueKey('dice'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Roll the Dice',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the dice or press Roll',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // Animated dice: rotation + horizontal shake while animating
          GestureDetector(
            onTap: _isRolling ? null : _rollDiceAnimated,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double rot = _rotation.value;
                final double shake = _shake.value;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: Transform.rotate(angle: rot, child: child),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: diceSize,
                  height: diceSize,
                  fit: BoxFit.contain,
                  key: ValueKey<int>(_dice),
                  errorBuilder: (context, error, stack) {
                    // Helpful guidance when the asset doesn't load:
                    return Container(
                      width: diceSize,
                      height: diceSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Image not found\n$imagePath\n\nPossible fixes:\n• Ensure images/1.png..6.png exist\n• Or update pubspec.yaml to register the folder: assets:\n  - images/\n• Or change this path to match your assets (e.g. assets/images/img$_dice.png)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'You rolled: $_dice',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isRolling ? null : _rollDiceAnimated,
                icon: const Icon(Icons.casino_rounded),
                label: const Text('Roll'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // white button
                  foregroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isRolling
                    ? null
                    : () => setState(() => _started = false),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Restart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
