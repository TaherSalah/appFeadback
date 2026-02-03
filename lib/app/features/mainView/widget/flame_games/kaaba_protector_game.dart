import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class KaabaProtectorGame extends BaseEducationalGame with TapCallbacks, DragCallbacks {
  late Bird bird;
  late Kaaba kaaba;
  double spawnTimer = 0;
  final Random random = Random();
  double enemySpeed = 100;

  @override
  Future<void> onLoad() async {
    // Beautiful desert sunset gradient
    add(BackgroundGradient(colors: [Colors.orange[900]!, Colors.orange[400]!, Colors.yellow[200]!]));
    
    kaaba = Kaaba();
    add(kaaba);

    bird = Bird();
    add(bird);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer > 2.0) {
      spawnElephant();
      spawnTimer = 0;
      enemySpeed += 2;
    }
  }

  void spawnElephant() {
    final elephant = Elephant(
      position: Vector2(size.x + 50, size.y - 100),
      speed: enemySpeed,
    );
    add(elephant);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    bird.dropStone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver) return;
    bird.position.x += event.localDelta.x;
    bird.position.x = bird.position.x.clamp(50, size.x - 50);
  }

  void createExplosion(Vector2 pos) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 25,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 400),
            speed: Vector2(random.nextDouble() * 500 - 250, -random.nextDouble() * 400),
            position: pos.clone(),
            child: CircleParticle(
              radius: 5,
              paint: Paint()..color = Colors.deepOrangeAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void restart() {
    super.restart();
    children.whereType<Elephant>().forEach((e) => e.removeFromParent());
    children.whereType<Stone>().forEach((s) => s.removeFromParent());
    enemySpeed = 100;
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
    
    // Draw some dunes
    final dunePaint = Paint()..color = Colors.brown[600]!.withOpacity(0.4);
    for(int i=0; i<3; i++) {
       canvas.drawCircle(Offset(gameRef.size.x * (i/2), gameRef.size.y), gameRef.size.x * 0.4, dunePaint);
    }
  }
}

class Kaaba extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  Kaaba() : super(size: Vector2(120, 120));

  @override
  void onMount() {
    super.onMount();
    position = Vector2(0, gameRef.size.y - 160);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(size.toRect(), paint);
    
    final goldPaint = Paint()..color = Colors.amber[600]!..strokeWidth = 4;
    canvas.drawRect(Rect.fromLTWH(0, 25, size.x, 15), goldPaint);
    
    // Detailed patterns
    final patternPaint = Paint()..color = Colors.amber[900]!..style = PaintingStyle.stroke;
    for (double i = 5; i < size.x; i += 20) {
       canvas.drawRect(Rect.fromLTWH(i, 28, 10, 10), patternPaint);
    }

    const textStyle = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'الكعبة المشرفة', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

class Bird extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  Bird() : super(size: Vector2(80, 50));

  @override
  void onMount() {
    super.onMount();
    position = Vector2(gameRef.size.x / 2, 120);
    anchor = Anchor.center;
  }

  void dropStone() {
    gameRef.add(Stone(position: position.clone()));
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey[300]!;
    // More detailed bird path
    final path = Path()
      ..moveTo(0, 25)
      ..relativeQuadraticBezierTo(20, -30, 40, 0)
      ..relativeQuadraticBezierTo(20, -30, 40, 0)
      ..lineTo(40, 50)
      ..close();
    canvas.drawPath(path, paint);
    
    const textStyle = TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'أبابيل', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, 30));
  }
}

class Elephant extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  final double speed;

  Elephant({required Vector2 position, required this.speed}) 
      : super(position: position, size: Vector2(90, 70));

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.x -= speed * dt;

    if (position.x < gameRef.kaaba.size.x) {
      gameRef.createExplosion(position + size/2);
      gameRef.gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey[700]!;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(15)), paint);
    
    // Trunk
    canvas.drawRect(Rect.fromLTWH(-10, 20, 20, 10), paint);

    const textStyle = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'فيل أبرهة', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

class Stone extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  double fallSpeed = 450;

  Stone({required Vector2 position}) : super(position: position, size: Vector2(25, 25));

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;

    for (final elephant in gameRef.children.whereType<Elephant>()) {
      if (position.distanceTo(elephant.position + elephant.size / 2) < 50) {
        gameRef.updateScore(10);
        gameRef.createExplosion(elephant.position + elephant.size / 2);
        elephant.removeFromParent();
        removeFromParent();
        return;
      }
    }

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Glowing stone
    final glowPaint = Paint()..color = Colors.redAccent.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 3, glowPaint);

    final paint = Paint()..color = Colors.grey[900]!;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    const textStyle = TextStyle(color: Colors.white, fontSize: 8);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'سجيل', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
