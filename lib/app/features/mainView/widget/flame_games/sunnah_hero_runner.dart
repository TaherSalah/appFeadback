import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'base_flame_game.dart';

class SunnahHeroRunner extends BaseEducationalGame with TapCallbacks {
  @override
  String get storageKey => 'sunnah_hero';
  
  static const List<Map<String, String>> hasanat = [
    {'text': 'بر الوالدين', 'emoji': '🤲'},
    {'text': 'الصلاة', 'emoji': '🕌'},
    {'text': 'الصدقة', 'emoji': '🪙'},
    {'text': 'الصدق', 'emoji': '🤝'},
    {'text': 'صلة الرحم', 'emoji': '👨‍👩‍👧‍👦'},
    {'text': 'مساعدة المحتاج', 'emoji': '🖐️'},
    {'text': 'الذكر', 'emoji': '📿'},
  ];

  static const List<Map<String, String>> sayyiat = [
    {'text': 'عقوق الوالدين', 'emoji': '🚫'},
    {'text': 'شرب الخمر', 'emoji': '🍷'},
    {'text': 'الكذب', 'emoji': '🤥'},
    {'text': 'الغيبة', 'emoji': '🤫'},
    {'text': 'السرقة', 'emoji': '🧤'},
    {'text': 'أذى الجار', 'emoji': '🥀'},
  ];

  HeroPlayer? hero;
  double spawnTimer = 0;
  final Random random = Random();
  double gameSpeed = 0; // Set in onResize
  double groundY = 0;

  @override
  Future<void> onLoad() async {
    // Elegant gradient sky
    add(BackgroundGradient(colors: [
      const Color(0xFF0D47A1), // Blue 900
      const Color(0xFF42A5F5), // Blue 400
      const Color(0xFFE3F2FD), // Blue 50
    ]));
    
    // Improved scrolling background with silhouettes
    add(ScrollingBackground(speedFactor: 0.2, color: Colors.blue[800]!.withOpacity(0.3), heightRatio: 0.5));
    add(ScrollingBackground(speedFactor: 0.5, color: Colors.blue[700]!.withOpacity(0.4), heightRatio: 0.25));

    hero = HeroPlayer();
    add(hero!);
    
    // Ground
    add(RectangleComponent(
      position: Vector2(0, size.y - size.y * 0.1),
      size: Vector2(size.x, size.y * 0.1),
      paint: Paint()..color = const Color(0xFF3E2723), // Brown 900
    ));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    groundY = size.y * 0.9;
    
    gameSpeed = size.x * 0.6; // Speed relative to screen width
    
    // Resize Hero
    if (hero != null && children.contains(hero!)) {
      final double baseUnit = min(size.x, size.y);
      hero!.size = Vector2(baseUnit * 0.15, baseUnit * 0.20);
      hero!.groundY = groundY;
      hero!.position = Vector2(size.x * 0.15, groundY);
      // Update physics constants based on size
      hero!.gravity = size.y * 2.5;
      hero!.jumpForce = -size.y * 0.95;
    }
    
    // Resize ground visual
    final ground = children.whereType<RectangleComponent>().firstOrNull;
    if (ground != null) {
      ground.position = Vector2(0, groundY);
      ground.size = Vector2(size.x, size.y - groundY);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    // Spawn faster as score increases
    final spawnInterval = max(1.2, 2.0 - (score * 0.05));
    
    if (spawnTimer > spawnInterval) {
      spawnObstacleOrDeed();
      spawnTimer = 0;
      gameSpeed += size.x * 0.01;
    }
  }

  void spawnObstacleOrDeed() {
    final double baseUnit = min(size.x, size.y);
    final itemSize = Vector2.all(baseUnit * 0.12);
    
    final isGoodDeed = random.nextDouble() > 0.3;
    final deed = isGoodDeed 
        ? hasanat[random.nextInt(hasanat.length)]
        : sayyiat[random.nextInt(sayyiat.length)];

    final item = RunnerItem(
      isGoodDeed: isGoodDeed,
      labelText: deed['text']!,
      emoji: deed['emoji']!,
      position: Vector2(size.x + itemSize.x, groundY - itemSize.y - (isGoodDeed && random.nextBool() ? itemSize.y * 1.5 : 0)), // Flying deeds
      size: itemSize,
      speed: gameSpeed,
    );
    add(item);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || hero == null) return;
    hero!.jump();
  }

  void createHitParticles(Vector2 pos, Color color) {
    final double baseUnit = min(size.x, size.y);
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 15,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, size.y * 0.5),
            speed: Vector2(random.nextDouble() * baseUnit - baseUnit/2, -random.nextDouble() * baseUnit/2),
            position: pos.clone(),
            child: CircleParticle(
              radius: baseUnit * 0.01,
              paint: Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void restart() {
    super.restart();
    children.whereType<RunnerItem>().forEach((item) => item.removeFromParent());
    onGameResize(size); // Reset speeds and hero
  }
}

class BackgroundGradient extends Component with HasGameRef {
  final List<Color> colors;
  BackgroundGradient({required this.colors});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), paint);
    
    // Add some stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final rand = Random(42);
    for(int i=0; i<30; i++) {
      canvas.drawCircle(Offset(rand.nextDouble() * gameRef.size.x, rand.nextDouble() * gameRef.size.y * 0.6), rand.nextDouble() * 2, starPaint);
    }
  }
}

class ScrollingBackground extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  final double speedFactor; // Relative to game width
  final Color color;
  final double heightRatio;
  double xOffset = 0;

  ScrollingBackground({required this.speedFactor, required this.color, required this.heightRatio});

  @override
  void render(Canvas canvas) {
    final h = gameRef.size.y * heightRatio;
    final yBase = gameRef.size.y - h - (gameRef.size.y * 0.1); // Above ground
    
    final paint = Paint()..color = color;
    
    final unitW = gameRef.size.x * 0.4;
    
    for (int i = 0; i < 5; i++) {
       final shapeX = (i * unitW - xOffset) % (gameRef.size.x + unitW) - unitW;
       
       final path = Path()
         ..moveTo(shapeX, yBase + h)
         ..lineTo(shapeX + unitW * 0.2, yBase + h * 0.4)
         ..lineTo(shapeX + unitW * 0.4, yBase + h * 0.2)
         ..lineTo(shapeX + unitW * 0.6, yBase + h * 0.4)
         ..lineTo(shapeX + unitW * 0.8, yBase + h)
         ..close();
       canvas.drawPath(path, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;
    xOffset += gameRef.size.x * speedFactor * dt;
  }
}

class HeroPlayer extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  double velocityY = 0;
  double gravity = 0; // Set in onResize
  double jumpForce = 0; // Set in onResize
  bool isJumping = false;
  double groundY = 0; // Set in onResize
  double _animationTime = 0;
  
  // Caching paints
  final Paint _bodyPaint = Paint()..color = Colors.white;
  final Paint _capePaint = Paint()..color = const Color(0xFF2E7D32); // Green 800
  final Paint _skinPaint = Paint()..color = const Color(0xFFFFE0B2); // Skin tone
  final Paint _kufiPaint = Paint()..color = Colors.white;
  final Paint _eyePaint = Paint()..color = Colors.black;
  final Paint _shadowPaint = Paint()..color = Colors.black26;

  HeroPlayer() : super(size: Vector2(60, 80), anchor: Anchor.bottomCenter);

  void jump() {
    if (!isJumping) {
      velocityY = jumpForce;
      isJumping = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    _animationTime += dt;
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (position.y > groundY) {
      position.y = groundY;
      velocityY = 0;
      isJumping = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final double w = size.x;
    final double h = size.y;
    
    // Draw Shadow on ground (fixed at ground level relative to player)
    final shadowWidth = w * (isJumping ? 0.6 : 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w/2, h + 5 - (position.y - groundY)), width: shadowWidth, height: 10),
      _shadowPaint
    );

    // Bounce/Stretch effect
    canvas.save();
    if (isJumping) {
      final stretch = (velocityY.abs() / 1000).clamp(0.0, 0.2);
      canvas.scale(1.0 - stretch, 1.0 + stretch);
      canvas.translate(w * stretch / 2, -h * stretch);
    }

    // Legs - Running animation
    final legCycle = sin(_animationTime * 15);
    final legY = h * 0.85;
    if (!isJumping) {
      // Left leg
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3 + legCycle * 5, legY, w * 0.15, h * 0.15), const Radius.circular(5)),
        _skinPaint
      );
      // Right leg
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55 - legCycle * 5, legY, w * 0.15, h * 0.15), const Radius.circular(5)),
        _skinPaint
      );
    } else {
      // Tucked legs when jumping
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, legY - 5, w * 0.15, h * 0.1), const Radius.circular(5)), _skinPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, legY - 5, w * 0.15, h * 0.1), const Radius.circular(5)), _skinPaint);
    }

    // Cape - Dynamic Billowing
    final capePath = Path();
    final billow = isJumping ? (velocityY * 0.05) : (sin(_animationTime * 10) * 10);
    capePath.moveTo(w * 0.2, h * 0.3);
    capePath.cubicTo(
      -w * 0.4, h * 0.4 + billow, 
      -w * 0.2, h * 0.9 + billow, 
      w * 0.1, h * 0.85
    );
    capePath.lineTo(w * 0.3, h * 0.3);
    canvas.drawPath(capePath, _capePaint);

    // Body (Thobe)
    final bodyPath = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..lineTo(w * 0.8, h * 0.3)
      ..lineTo(w * 0.9, h * 0.85)
      ..lineTo(w * 0.1, h * 0.85)
      ..close();
    canvas.drawPath(bodyPath, _bodyPaint);
    
    // Head
    final headCenter = Offset(w / 2, h * 0.2);
    final headRadius = w * 0.25;
    canvas.drawCircle(headCenter, headRadius, _skinPaint);
    
    // Kufi (Cap)
    final kufiPath = Path()
      ..addArc(Rect.fromCircle(center: headCenter, radius: headRadius), -pi, pi);
    canvas.drawPath(kufiPath, _kufiPaint);

    // Eyes
    final eyeY = h * 0.18;
    final blink = sin(_animationTime * 2).abs() < 0.05 ? 0.1 : 1.0;
    canvas.drawCircle(Offset(w * 0.6, eyeY), 3 * blink, _eyePaint);
    canvas.drawCircle(Offset(w * 0.75, eyeY), 3 * blink, _eyePaint);

    canvas.restore();
  }
}

class RunnerItem extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  final bool isGoodDeed;
  final String labelText;
  final String emoji;
  final double speed;

  RunnerItem({
    required this.isGoodDeed, 
    required this.labelText,
    required this.emoji,
    required Vector2 position, 
    required Vector2 size, 
    required this.speed
  }) : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.x -= speed * dt;

    if (gameRef.hero != null) {
      final hero = gameRef.hero!;
      // Account for bottomCenter anchor of hero
      final heroRect = Rect.fromLTWH(
        hero.position.x - hero.size.x * 0.4, 
        hero.position.y - hero.size.y * 0.9, 
        hero.size.x * 0.8, 
        hero.size.y * 0.8
      );
      
      final itemRect = Rect.fromLTWH(position.x, position.y, size.x, size.y);

      if (heroRect.overlaps(itemRect)) {
        if (isGoodDeed) {
          gameRef.updateScore(5);
          gameRef.createHitParticles(position + size/2, Colors.amberAccent);
        } else {
          gameRef.createHitParticles(position + size/2, Colors.redAccent);
          gameRef.gameOver();
        }
        removeFromParent();
      }
    }

    if (position.x < -size.x * 2) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isGoodDeed ? Colors.amberAccent : Colors.deepPurple;
    final double w = size.x;
    final double h = size.y;
    
    // Smooth floating animation
    final floatY = sin(gameRef.elapsedTime * 5) * 5;
    canvas.translate(0, floatY);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.5, glowPaint);

    // Main shape with gradient
    final shapePaint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withRed((color.red - 50).clamp(0, 255))],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    if (isGoodDeed) {
      canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, shapePaint);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9), Radius.circular(w * 0.2)), shapePaint);
    }

    // Emoji icon
    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: w * 0.55)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2));
    
    // Tag banner for the text
    final labelFontSize = w * 0.25;
    final labelStyle = TextStyle(
                  fontFamily: "cairo",
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: labelFontSize,
      shadows: const [Shadow(blurRadius: 4, color: Colors.black54)]
    );
    
    final labelPainter = TextPainter(
      text: TextSpan(text: labelText, style: labelStyle),
      textDirection: TextDirection.rtl,
    )..layout();

    // Banner Background
    final bannerW = labelPainter.width + 12;
    final bannerH = labelPainter.height + 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH((w - bannerW) / 2, h + 5, bannerW, bannerH), const Radius.circular(4)),
      Paint()..color = Colors.black45
    );
    
    labelPainter.paint(canvas, Offset((w - labelPainter.width) / 2, h + 7));
  }
}

