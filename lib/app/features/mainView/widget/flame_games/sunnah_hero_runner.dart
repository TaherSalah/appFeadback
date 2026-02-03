import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class SunnahHeroRunner extends BaseEducationalGame with TapCallbacks {
  late HeroPlayer hero;
  double spawnTimer = 0;
  final Random random = Random();
  double gameSpeed = 300;

  @override
  Future<void> onLoad() async {
    // Elegant gradient sky
    add(BackgroundGradient(colors: [Colors.blue[900]!, Colors.blue[400]!]));
    
    // Improved scrolling background with silhouettes
    add(ScrollingBackground(speed: 40, color: Colors.blue[800]!.withOpacity(0.3), height: 300));
    add(ScrollingBackground(speed: 80, color: Colors.blue[700]!.withOpacity(0.4), height: 200));

    hero = HeroPlayer();
    add(hero);
    
    add(RectangleComponent(
      position: Vector2(0, size.y - 40),
      size: Vector2(size.x, 40),
      paint: Paint()..color = Colors.brown[900]!,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer > 1.5) {
      spawnObstacleOrDeed();
      spawnTimer = 0;
      gameSpeed += 5;
    }
  }

  void spawnObstacleOrDeed() {
    final isGoodDeed = random.nextDouble() > 0.3;
    final item = RunnerItem(
      isGoodDeed: isGoodDeed,
      position: Vector2(size.x + 50, size.y - 90),
      speed: gameSpeed,
    );
    add(item);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    hero.jump();
  }

  void createHitParticles(Vector2 pos, Color color) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 15,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 300),
            speed: Vector2(random.nextDouble() * 300 - 150, -random.nextDouble() * 200),
            position: pos.clone(),
            child: CircleParticle(
              radius: 4,
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
    gameSpeed = 300;
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
      canvas.drawCircle(Offset(rand.nextDouble() * gameRef.size.x, rand.nextDouble() * gameRef.size.y * 0.6), rand.nextDouble() * 1.5, starPaint);
    }
  }
}

class ScrollingBackground extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  final double speed;
  final Color color;
  final double height;
  double xOffset = 0;

  ScrollingBackground({required this.speed, required this.color, this.height = 0});

  @override
  void render(Canvas canvas) {
    final h = height > 0 ? height : gameRef.size.y;
    final y = height > 0 ? gameRef.size.y - height - 40 : 0.0;
    
    final paint = Paint()..color = color;
    
    for (int i = 0; i < 5; i++) {
       final shapeX = (i * 250 - xOffset) % (gameRef.size.x + 250) - 100;
       // Stylized mosque silhouette or hill
       final path = Path()
         ..moveTo(shapeX, h + y)
         ..lineTo(shapeX + 50, y + h * 0.4)
         ..lineTo(shapeX + 100, y + h * 0.2)
         ..lineTo(shapeX + 150, y + h * 0.4)
         ..lineTo(shapeX + 200, h + y)
         ..close();
       canvas.drawPath(path, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    xOffset += speed * dt;
  }
}

class HeroPlayer extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  double velocityY = 0;
  final double gravity = 1500;
  final double jumpForce = -600;
  bool isJumping = false;
  late double groundY;

  HeroPlayer() : super(size: Vector2(60, 80));

  @override
  void onMount() {
    super.onMount();
    groundY = gameRef.size.y - 40;
    position = Vector2(100, groundY - size.y);
  }

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
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), paint);
    
    // Cape
    const textStyle = TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'بطل السنة', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

class RunnerItem extends PositionComponent with HasGameRef<SunnahHeroRunner> {
  final bool isGoodDeed;
  final double speed;

  RunnerItem({required this.isGoodDeed, required Vector2 position, required this.speed}) 
      : super(position: position, size: Vector2(40, 40));

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.x -= speed * dt;

    if (position.distanceTo(gameRef.hero.position) < 40) {
      if (isGoodDeed) {
        gameRef.updateScore(5);
        gameRef.createHitParticles(position + size/2, Colors.amberAccent);
      } else {
        gameRef.createHitParticles(position + size/2, Colors.redAccent);
        gameRef.gameOver();
      }
      removeFromParent();
    }

    if (position.x < -50) {
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
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), paint);
    }
    
    const textStyle = TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: isGoodDeed ? 'حسنة' : 'عقبة', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
