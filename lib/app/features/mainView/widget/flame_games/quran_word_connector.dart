import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'base_flame_game.dart';

class QuranWordConnector extends BaseEducationalGame with TapCallbacks {
  @override
  String get storageKey => 'quran_word_connector';
  
  final List<String> targetWords = [
    // Arkan al-Islam
    'الشهادة', 'الصلاة', 'الزكاة', 'الصيام', 'الحج',
    // Arkan al-Iman
    'بالله', 'الملائكة', 'الكتب', 'الرسل', 'اليوم الآخر', 'القدر',
    // Islamic Concepts & Values
    'التوحيد', 'السنة', 'المسجد', 'الكعبة', 'العمرة', 'الذكر', 'التسبيح', 
    'الحمد', 'استغفار', 'الصدق', 'الأمانة', 'الصبر', 'التقوى', 'الإحسان',
    'الجنة', 'محمد', 'قرآن', 'إسلام', 'إيمان'
  ];
  String currentTarget = '';
  String selectedWord = '';
  final List<LetterBubble> bubbles = [];
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    add(CosmicBackground());
  }

  @override
  void onGameResize(Vector2 size) {
    if (size.x < 100 || size.y < 100) return;
    super.onGameResize(size);
    startNewLevel();
  }

  void startNewLevel() {
    if (size.x < 100 || size.y < 100) return;

    currentTarget = targetWords[random.nextInt(targetWords.length)];
    selectedWord = '';
    
    bubbles.forEach((b) => b.removeFromParent());
    bubbles.clear();

    final letters = currentTarget.split('');
    final extraLetters = ['ا', 'ب', 'ت', 'م', 'ل', 'و', 'ي', 'ن', 'س', 'ر'];
    final allLetters = [...letters];
    
    while (allLetters.length < 10) {
      allLetters.add(extraLetters[random.nextInt(extraLetters.length)]);
    }
    allLetters.shuffle();
    
    final double baseUnit = min(size.x, size.y);
    final double bubbleSize = baseUnit * 0.18;

    for (int i = 0; i < allLetters.length; i++) {
      final x = random.nextDouble() * (size.x - bubbleSize - 40) + 20 + bubbleSize/2;
      final y = random.nextDouble() * (size.y * 0.45) + (size.y * 0.35);
      
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
    
    // Star explosion effect
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 12,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(random.nextDouble() * 200 - 100, random.nextDouble() * 200 - 100),
            position: bubble.position.clone(),
            child: CircleParticle(
              radius: 3, 
              paint: Paint()..color = Colors.cyanAccent.withOpacity(0.8)
            ),
          ),
        ),
      ),
    );

    if (currentTarget.startsWith(selectedWord)) {
      bubble.removeFromParent();
      if (selectedWord == currentTarget) {
        updateScore(50);
        _celebrateWin();
        Future.delayed(const Duration(milliseconds: 800), () => startNewLevel());
      }
    } else {
      selectedWord = '';
      gameOver();
    }
  }

  void _celebrateWin() {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 50,
          lifespan: 2.0,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(random.nextDouble() * 400 - 200, random.nextDouble() * 400 - 200),
            position: size / 2,
            child: CircleParticle(
              radius: random.nextDouble() * 4 + 2,
              paint: Paint()..color = Colors.amberAccent
            ),
          ),
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final double headerY = size.y * 0.12;
    
    // Premium Typography
    final targetStyle = TextStyle(
                  fontFamily: "cairo",
      color: Colors.white, 
      fontSize: size.x * 0.09, 
      fontWeight: FontWeight.bold,
      shadows: [const Shadow(color: Colors.cyanAccent, blurRadius: 15)]
    );
    
    final targetPainter = TextPainter(
      text: TextSpan(text: 'الكلمة: $currentTarget', style: targetStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    targetPainter.paint(canvas, Offset((size.x - targetPainter.width) / 2, headerY));

    final progressStyle = TextStyle(
                  fontFamily: "cairo",
      color: Colors.amberAccent, 
      fontSize: size.x * 0.06, 
      fontWeight: FontWeight.w600,
      letterSpacing: 4
    );
    
    final progressPainter = TextPainter(
      text: TextSpan(text: 'التقدم: $selectedWord', style: progressStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    progressPainter.paint(canvas, Offset((size.x - progressPainter.width) / 2, headerY + targetPainter.height + 10));
  }

  @override
  void restart() {
    super.restart();
    startNewLevel();
  }
}

class CosmicBackground extends Component with HasGameRef<QuranWordConnector> {
  final List<Offset> stars = List.generate(80, (index) => Offset(Random().nextDouble(), Random().nextDouble()));

  @override
  void render(Canvas canvas) {
    // Deep Space Gradient
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [const Color(0xFF1A237E), const Color(0xFF000000)],
      ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), paint);

    // Draw Shimmering Stars
    final starPaint = Paint()..color = Colors.white;
    for (var star in stars) {
      final double gameTime = gameRef.elapsedTime;
      final opacity = 0.2 + (sin(gameTime * 2 + star.dx * 100) * 0.15);
      canvas.drawCircle(
        Offset(star.dx * gameRef.size.x, star.dy * gameRef.size.y), 
        Random(star.hashCode).nextDouble() * 1.5, 
        starPaint..color = Colors.white.withOpacity(opacity.clamp(0, 1))
      );
    }
    
    // Layered Nebulas
    _drawNebula(canvas, Offset(gameRef.size.x * 0.3, gameRef.size.y * 0.4), Colors.purple[900]!.withOpacity(0.15), 200);
    _drawNebula(canvas, Offset(gameRef.size.x * 0.7, gameRef.size.y * 0.7), Colors.blue[900]!.withOpacity(0.15), 250);
  }

  void _drawNebula(Canvas canvas, Offset center, Color color, double radius) {
    canvas.drawCircle(
      center, radius, 
      Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
    );
  }
}

class LetterBubble extends PositionComponent with TapCallbacks, HasGameRef<QuranWordConnector> {
  final String letter;
  double _wobbleTime = 0;
  
  LetterBubble({required this.letter, required Vector2 position, required Vector2 size}) 
      : super(position: position, size: size, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;
    
    _wobbleTime += dt;
    
    // Gentle floating motion
    position.y += sin(_wobbleTime * 1.5 + position.x) * 0.3;
    position.x += cos(_wobbleTime * 1.2 + position.y) * 0.2;
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.onLetterTapped(this);
  }

  @override
  void render(Canvas canvas) {
    final double radius = size.x / 2;
    
    // Glassmorphism effect
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Inner Glow
    final innerGlow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.cyanAccent.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(radius, radius), radius: radius));
    
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius, radius), radius, innerGlow);
    
    // Glowing border
    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    // Letter Styling
    final textStyle = TextStyle(
                  fontFamily: "cairo",
      color: Colors.white, 
      fontSize: size.x * 0.55, 
      fontWeight: FontWeight.bold,
      shadows: [const Shadow(color: Colors.white70, blurRadius: 8)]
    );
    
    final textPainter = TextPainter(
      text: TextSpan(text: letter, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

