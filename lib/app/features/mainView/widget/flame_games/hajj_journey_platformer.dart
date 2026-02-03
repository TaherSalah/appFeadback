import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class HajjJourneyGame extends BaseEducationalGame with TapCallbacks {
  late Pilgrim pilgrim;
  final List<Platform> platforms = [];
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Elegant Hajj environment gradient
    add(BackgroundGradient(colors: [Colors.blue[100]!, Colors.blue[300]!, Colors.yellow[100]!]));
    
    add(pilgrim = Pilgrim());
    
    spawnPlatform(Vector2(100, size.y - 120), 200, 'البداية');
    
    for (int i = 1; i < 5; i++) {
      spawnPlatform(
        Vector2(i * 300.0 + 100, size.y - 120 - random.nextDouble() * 100),
        180,
        ['الصفا', 'المروة', 'عرفة', 'مزدلفة'][i % 4],
      );
    }
  }

  void spawnPlatform(Vector2 pos, double width, String label) {
    final platform = Platform(position: pos, width: width, label: label);
    platforms.add(platform);
    add(platform);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    if (pilgrim.position.x > size.x / 2) {
       final scrollAmount = pilgrim.velocityX * dt;
       platforms.forEach((p) => p.position.x -= scrollAmount);
       pilgrim.position.x -= scrollAmount;
       
       if (platforms.last.position.x < size.x) {
         spawnPlatform(
           Vector2(platforms.last.position.x + 300, size.y - 120 - random.nextDouble() * 100),
           180,
           ['الجمارات', 'طواف الإفاضة', 'السعي'][random.nextInt(3)],
         );
       }
    }

    if (pilgrim.position.y > size.y) {
      gameOver();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    pilgrim.jump();
  }

  @override
  void restart() {
    super.restart();
    platforms.forEach((p) => p.removeFromParent());
    platforms.clear();
    onLoad();
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
    
    // Some mountain shapes
    final mtPaint = Paint()..color = Colors.brown[300]!.withOpacity(0.3);
    for(int i=0; i<4; i++) {
       canvas.drawCircle(Offset(gameRef.size.x * (i/3), gameRef.size.y), gameRef.size.x * 0.3, mtPaint);
    }
  }
}

class Pilgrim extends PositionComponent with HasGameRef<HajjJourneyGame> {
  double velocityY = 0;
  double velocityX = 200;
  final double gravity = 1200;
  final double jumpForce = -600;
  bool isJumping = false;

  Pilgrim() : super(size: Vector2(60, 80));

  @override
  void onMount() {
    super.onMount();
    position = Vector2(100, gameRef.size.y - 250);
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
    position.x += velocityX * dt;

    for (final platform in gameRef.platforms) {
      if (velocityY > 0 && 
          position.x + size.x > platform.position.x && 
          position.x < platform.position.x + platform.width &&
          position.y + size.y >= platform.position.y &&
          position.y + size.y <= platform.position.y + 20) {
        position.y = platform.position.y - size.y;
        velocityY = 0;
        isJumping = false;
        gameRef.updateScore(1);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10)), paint);
    
    // Ihram texture
    final ihramPaint = Paint()..color = Colors.grey[300]!..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(0, 40, size.x, 2), ihramPaint);

    const textStyle = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'الحاج', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

class Platform extends PositionComponent with HasGameRef<HajjJourneyGame> {
  final double width;
  final String label;

  Platform({required Vector2 position, required this.width, required this.label}) 
      : super(position: position, size: Vector2(width, 45));

  @override
  void render(Canvas canvas) {
    // Marble platform
    final paint = Paint()..color = Colors.white70;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), paint);
    
    final borderPaint = Paint()..color = Colors.brown[200]!..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), borderPaint);
    
    const textStyle = TextStyle(color: Colors.brown, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
