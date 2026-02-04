import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class QuranWordConnector extends BaseEducationalGame with TapCallbacks {
  final List<String> targetWords = ['الله', 'محمد', 'إسلام', 'قرآن', 'صلاة', 'إيمان', 'جنة'];
  String currentTarget = '';
  String selectedWord = '';
  final List<LetterBubble> bubbles = [];
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Cosmic starry background for a peaceful puzzle feel
    add(BackgroundGradient(colors: [
      const Color(0xFF1A237E), // Indigo 900
      const Color(0xFF311B92), // Deep Purple 900
      const Color(0xFF000000), // Black
    ]));
    
    // Defer level start to first resize so we know screen bounds
  }

  @override
  void onGameResize(Vector2 size) {
    if (size.x < 100 || size.y < 100) return;
    super.onGameResize(size);
    // If not valid target or bubbles Empty (bad init), restart level
    if (currentTarget.isEmpty || bubbles.isEmpty) {
      startNewLevel();
    } else {
       // Resize bubbles? Re-randomize positions to fit new screen
       // For simplicity, let's just restart level on resize to ensure bounds are safe
       // Or iterate and clamp positions.
       startNewLevel(); 
    }
  }

  void startNewLevel() {
    if (size.x < 100 || size.y < 100) return; // Not ready

    currentTarget = targetWords[random.nextInt(targetWords.length)];
    selectedWord = '';
    
    // Clear existing
    bubbles.forEach((b) => b.removeFromParent());
    bubbles.clear();

    final letters = currentTarget.split('');
    final extraLetters = ['ا', 'ب', 'ت', 'م', 'ل', 'و', 'ي', 'ن', 'س', 'ر'];
    final allLetters = [...letters];
    
    // Add extras until we have enough
    while (allLetters.length < 10) {
      allLetters.add(extraLetters[random.nextInt(extraLetters.length)]);
    }
    allLetters.shuffle();
    
    final double baseUnit = min(size.x, size.y);
    final double bubbleSize = baseUnit * 0.18;

    for (int i = 0; i < allLetters.length; i++) {
      // Ensure bubbles spawn within a safe central area
      final x = random.nextDouble() * (size.x - bubbleSize - 20) + 10 + bubbleSize/2;
      final y = random.nextDouble() * (size.y * 0.5) + (size.y * 0.3); // Lower half screen
      
      final bubble = LetterBubble(
        letter: allLetters[i],
        position: Vector2(x, y),
        size: Vector2.all(bubbleSize),
      );
      bubbles.add(bubble);
      add(bubble);
    }
  }

  void onLetterTapped(LetterBubble bubble) {
    if (isGameOver) return;
    
    selectedWord += bubble.letter;
    
    // Celestial particles on tap
    final double baseUnit = min(size.x, size.y);
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(random.nextDouble() * baseUnit - baseUnit/2, random.nextDouble() * baseUnit - baseUnit/2),
            position: bubble.position.clone(),
            child: CircleParticle(radius: baseUnit * 0.01, paint: Paint()..color = Colors.amberAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)),
          ),
        ),
      ),
    );

    if (currentTarget.startsWith(selectedWord)) {
      bubble.removeFromParent();
      if (selectedWord == currentTarget) {
        updateScore(50);
        // Delay slighty before new level
        Future.delayed(const Duration(milliseconds: 500), () => startNewLevel());
      }
    } else {
      // Wrong letter - reset current progress but not gameover immediately? 
      // Or maybe just flash red. For now, strict game over on wrong sequence as per original.
      selectedWord = '';
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dynamic text sizing
    final double headerSize = size.x * 0.08;
    
    final textStyle = TextStyle(color: Colors.white, fontSize: headerSize, fontWeight: FontWeight.bold, letterSpacing: 2, shadows: [Shadow(color: Colors.blueAccent, blurRadius: 10)]);
    final textPainter = TextPainter(
      text: TextSpan(text: 'الكلمة: $currentTarget', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y * 0.1));

    final progressStyle = TextStyle(color: Colors.amberAccent, fontSize: headerSize * 0.8, fontWeight: FontWeight.w500);
    final progressPainter = TextPainter(
      text: TextSpan(text: 'التقدم: $selectedWord', style: progressStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    progressPainter.paint(canvas, Offset((size.x - progressPainter.width) / 2, size.y * 0.1 + headerSize * 1.5));
  }

  @override
  void restart() {
    super.restart();
    currentTarget = ''; // Force re-init
    startNewLevel();
  }
}

class BackgroundGradient extends Component with HasGameRef {
  final List<Color> colors;
  BackgroundGradient({required this.colors});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: colors,
      ).createShader(gameRef.size.toRect());
    canvas.drawRect(gameRef.size.toRect(), paint);
    
    // Floating stars background
    final starPaint = Paint()..color = Colors.white.withOpacity(0.3);
    final rand = Random(123);
    for(int i=0; i<50; i++) {
       canvas.drawCircle(Offset(rand.nextDouble() * gameRef.size.x, rand.nextDouble() * gameRef.size.y), rand.nextDouble() * 2, starPaint);
    }
  }
}

class LetterBubble extends PositionComponent with TapCallbacks, HasGameRef<QuranWordConnector> {
  final String letter;
  double speedY;
  int directionY = 1;

  LetterBubble({required this.letter, required Vector2 position, required Vector2 size}) 
      : speedY = 0, // Will set relative speed
        super(position: position, size: size) {
          speedY = 30 + Random().nextDouble() * 50; 
        }

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
    // Adjust speed relative to screen height
    speedY = gameRef.size.y * 0.05 + Random().nextDouble() * (gameRef.size.y * 0.05);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.y += speedY * directionY * dt;
    final double lowerBound = gameRef.size.y - size.y;
    final double upperBound = gameRef.size.y * 0.25; // Don't go too high into text area
    
    if (position.y > lowerBound || position.y < upperBound) {
      directionY *= -1;
      position.y = position.y.clamp(upperBound, lowerBound);
    }
    
    position.x += sin(gameRef.elapsedTime * 2 + position.y) * (gameRef.size.x * 0.002);
    position.x = position.x.clamp(size.x/2, gameRef.size.x - size.x/2);
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.onLetterTapped(this);
  }

  @override
  void render(Canvas canvas) {
    // Celestial bubble
    final paint = Paint()
      ..color = Colors.indigo[400]!.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    // Glowing border
    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.x * 0.04
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, borderPaint);

    // Dynamic Font Size
    final fontSize = size.x * 0.5;
    final textStyle = TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: letter, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

