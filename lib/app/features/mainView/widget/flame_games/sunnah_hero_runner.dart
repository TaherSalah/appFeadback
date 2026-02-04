import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class SunnahHeroRunner extends BaseEducationalGame with TapCallbacks {
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
      hero!.position = Vector2(size.x * 0.15, groundY - hero!.size.y);
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
    final item = RunnerItem(
      isGoodDeed: isGoodDeed,
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
      ).createShader(gameRef.size.toRect());
    canvas.drawRect(gameRef.size.toRect(), paint);
    
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

  HeroPlayer() : super(size: Vector2(60, 80));

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

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (position.y > groundY - size.y) {
      position.y = groundY - size.y;
      velocityY = 0;
      isJumping = false;
    }
  }

  @override
  void render(Canvas canvas) {
    // Hero with a cape!
    final paint = Paint()..color = Colors.green[500]!;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)), paint);
    
    // Cape animation based on velocity
    final capePath = Path();
    capePath.moveTo(0, size.y * 0.2);
    capePath.quadraticBezierTo(-size.x * 0.5, size.y * 0.3 + (velocityY * 0.02), -size.x * 0.2, size.y * 0.8);
    capePath.lineTo(0, size.y * 0.3);
    canvas.drawPath(capePath, Paint()..color = Colors.green[700]!);
    
    // Face
    canvas.drawRect(Rect.fromLTWH(size.x * 0.6, size.y * 0.2, size.x * 0.3, size.y * 0.2), Paint()..color = const Color(0xFFFFCCBC));

    const textStyle = TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'بطل السنة', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y * 0.5));
  }
}

class RunnerItem extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  final bool isGoodDeed;
  final double speed;

  RunnerItem({required this.isGoodDeed, required Vector2 position, required Vector2 size, required this.speed}) 
      : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.x -= speed * dt;

    if (gameRef.hero != null && position.distanceTo(gameRef.hero!.position + gameRef.hero!.size/2) < (size.x + gameRef.hero!.size.x)/2.5) {
      if (isGoodDeed) {
        gameRef.updateScore(5);
        gameRef.createHitParticles(position + size/2, Colors.amberAccent);
      } else {
        gameRef.createHitParticles(position + size/2, Colors.redAccent);
        gameRef.gameOver();
      }
      removeFromParent();
    }

    if (position.x < -size.x * 2) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isGoodDeed ? Colors.amberAccent : Colors.purpleAccent;
    
    // Glow
    final glowPaint = Paint()..color = color.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 5, glowPaint);

    final paint = Paint()..color = color;
    if (isGoodDeed) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
      // Star Icon
      const textStyle = TextStyle(fontSize: 20); // Emoji size relative?
      final textPainter = TextPainter(
        text: const TextSpan(text: '⭐', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
       textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), paint);
       // Warning Icon
      const textStyle = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
      final textPainter = TextPainter(
        text: const TextSpan(text: '!', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
       textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
    }
    
    // Label text
    final fontSize = size.x * 0.25;
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2)]);
    final textPainter = TextPainter(
      text: TextSpan(text: isGoodDeed ? 'حسنة' : 'عقبة', style: textStyle.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y + 2));
  }
}

