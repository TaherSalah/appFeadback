import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class QuranWordConnector extends BaseEducationalGame with TapCallbacks {
  final List<String> targetWords = ['الله', 'محمد', 'إسلام', 'قرآن', 'صلاة', 'إيمان', 'جنة'];
  late String currentTarget;
  String selectedWord = '';
  final List<LetterBubble> bubbles = [];
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Cosmic starry background for a peaceful puzzle feel
    add(BackgroundGradient(colors: [Colors.indigo[900]!, Colors.purple[900]!, Colors.black]));
    startNewLevel();
  }

  void startNewLevel() {
    currentTarget = targetWords[random.nextInt(targetWords.length)];
    selectedWord = '';
    bubbles.forEach((b) => b.removeFromParent());
    bubbles.clear();

    final letters = currentTarget.split('');
    final extraLetters = ['ا', 'ب', 'ت', 'م', 'ل', 'و', 'ي', 'ن'];
    final allLetters = [...letters];
    while (allLetters.length < 10) {
      allLetters.add(extraLetters[random.nextInt(extraLetters.length)]);
    }
    allLetters.shuffle();

    for (int i = 0; i < allLetters.length; i++) {
      final bubble = LetterBubble(
        letter: allLetters[i],
        position: Vector2(random.nextDouble() * (size.x - 100) + 50, random.nextDouble() * (size.y - 300) + 150),
      );
      bubbles.add(bubble);
      add(bubble);
    }
  }

  void onLetterTapped(LetterBubble bubble) {
    if (isGameOver) return;
    
    selectedWord += bubble.letter;
    
    // Celestial particles
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(random.nextDouble() * 300 - 150, random.nextDouble() * 300 - 150),
            position: bubble.position.clone(),
            child: CircleParticle(radius: 3, paint: Paint()..color = Colors.amberAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)),
          ),
        ),
      ),
    );

    if (currentTarget.startsWith(selectedWord)) {
      bubble.removeFromParent();
      if (selectedWord == currentTarget) {
        updateScore(50);
        startNewLevel();
      }
    } else {
      selectedWord = '';
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final textStyle = const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2);
    final textPainter = TextPainter(
      text: TextSpan(text: 'الكلمة: $currentTarget', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, 60));

    final progressStyle = const TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.w500);
    final progressPainter = TextPainter(
      text: TextSpan(text: 'التقدم: $selectedWord', style: progressStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    progressPainter.paint(canvas, Offset((size.x - progressPainter.width) / 2, 110));
  }

  @override
  void restart() {
    super.restart();
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
    
    // Floating stars
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

  LetterBubble({required this.letter, required Vector2 position}) 
      : speedY = 30 + Random().nextDouble() * 50,
        super(position: position, size: Vector2(80, 80));

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.y += speedY * directionY * dt;
    if (position.y > gameRef.size.y - 120 || position.y < 180) {
      directionY *= -1;
    }
    
    position.x += sin(gameRef.elapsedTime * 2) * 1.0;
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
    
    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, borderPaint);

    final textStyle = const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: letter, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
