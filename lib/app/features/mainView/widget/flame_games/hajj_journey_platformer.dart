import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class HajjJourneyGame extends BaseEducationalGame with TapCallbacks {
  Pilgrim? pilgrim;
  final List<Platform> platforms = [];
  final Random random = Random();
  double gameScrollSpeed = 0; // Dynamic scroll

  @override
  Future<void> onLoad() async {
    // Elegant Hajj environment gradient (Dawn/Day)
    add(BackgroundGradient(colors: [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFBBDEFB), // Blue 100
      const Color(0xFFFFF9C4), // Yellow 100 (Sun)
    ]));
    
    // Initial setup waits for resize for correct positioning
    // But we add pilgrim to be ready
    pilgrim = Pilgrim();
    add(pilgrim!);
  }

  @override
  void onGameResize(Vector2 size) {
    if (size.x < 100 || size.y < 100) return; // Ignore invalid sizes
    super.onGameResize(size);
    gameScrollSpeed = size.x * 0.3;
    
    final double baseUnit = min(size.x, size.y);
    
    // Resize Pilgrim
    if (pilgrim != null && children.contains(pilgrim!)) {
      pilgrim!.size = Vector2(baseUnit * 0.15, baseUnit * 0.2);
       // Reset position if fell off or first load
      if (pilgrim!.position.y > size.y || pilgrim!.position == Vector2.zero()) {
         pilgrim!.position = Vector2(size.x * 0.1, size.y * 0.7);
         pilgrim!.velocityY = 0;
      }
      
      // Update physics
      pilgrim!.gravity = size.y * 2.0;
      pilgrim!.jumpForce = -size.y * 0.85;
      pilgrim!.moveSpeed = size.x * 0.3; 
    }

    // Re-generate platforms if empty or if they were created with 0 size
    if (platforms.isEmpty || (platforms.isNotEmpty && platforms.first.size.x == 0)) {
      _generateInitialPlatforms(size);
    } 
  }

  void _generateInitialPlatforms(Vector2 size) {
    platforms.forEach((p) => p.removeFromParent());
    platforms.clear();
    
    // Starting platform
    spawnPlatform(Vector2(size.x * 0.1, size.y * 0.8), size.x * 0.4, 'البداية');
    
    // Next platforms
    double currentX = size.x * 0.6;
    for (int i = 1; i < 5; i++) {
      final double width = size.x * 0.35;
      final double y = size.y * 0.6 + random.nextDouble() * (size.y * 0.2); // Random height in lower half
      
      spawnPlatform(
        Vector2(currentX, y),
        width,
        ['الصفا', 'المروة', 'عرفة', 'مزدلفة'][i % 4],
      );
      currentX += width + size.x * 0.2; // Gap
    }
  }

  void spawnPlatform(Vector2 pos, double width, String label) {
    final platform = Platform(position: pos, width: width, label: label, height: size.y * 0.06);
    platforms.add(platform);
    add(platform);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || pilgrim == null) return;

    // Scrolling logic: Camera follows pilgrim? Or pilgrim stays left and world moves?
    // Let's keep pilgrim moving right, but if he goes past center, move world left
    if (pilgrim!.position.x > size.x * 0.4) {
       final scrollAmount = (pilgrim!.position.x - size.x * 0.4);
       
       // Move platforms
       for (var p in platforms) {
         p.position.x -= scrollAmount;
       }
       // Keep pilgrim fixed visually at center relative to scrolling
       pilgrim!.position.x = size.x * 0.4;
       
       // Recycle platforms
       if (platforms.first.position.x + platforms.first.width < 0) {
         final p = platforms.removeAt(0);
         p.removeFromParent();
       }
       
       // Spawn new ones
       if (platforms.last.position.x < size.x) {
         final double width = size.x * 0.35 + random.nextDouble() * (size.x * 0.1);
         spawnPlatform(
           Vector2(platforms.last.position.x + platforms.last.width + size.x * 0.25, size.y * 0.5 + random.nextDouble() * (size.y * 0.3)),
           width,
           ['الجمارات', 'طواف الإفاضة', 'السعي', 'منى'][random.nextInt(4)],
         );
       }
    }

    if (pilgrim!.position.y > size.y) {
      gameOver();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || pilgrim == null) return;
    pilgrim!.jump();
  }

  @override
  void restart() {
    super.restart();
    platforms.forEach((p) => p.removeFromParent());
    platforms.clear();
    // Reset pilgrim
    if (pilgrim != null) {
       pilgrim!.position = Vector2.zero(); // Will trigger reset in resize logic or:
       pilgrim!.velocityY = 0;
       pilgrim!.position = Vector2(size.x * 0.1, size.y * 0.7);
    }
    _generateInitialPlatforms(size);
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
    
    // Mountains in distance
    final mtPaint = Paint()..color = Colors.brown[300]!.withOpacity(0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset(gameRef.size.x * 0.2, gameRef.size.y), width: gameRef.size.x * 0.6, height: gameRef.size.y * 0.4), mtPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(gameRef.size.x * 0.8, gameRef.size.y), width: gameRef.size.x * 0.8, height: gameRef.size.y * 0.5), mtPaint);
  }
}

class Pilgrim extends PositionComponent with HasGameRef<HajjJourneyGame> {
  double velocityY = 0;
  double moveSpeed = 0;
  double gravity = 1000;
  double jumpForce = -500;
  bool isJumping = false;

  Pilgrim() : super(size: Vector2(60, 80));

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
    position.x += moveSpeed * dt;

    // Platform collision
    isJumping = true; // Assume jumping/falling until collision found
    for (final platform in gameRef.platforms) {
      // Simple AABB collision detection adjusted for landing on top
      final pRect = platform.toRect();
      final myRect = toRect();
      
      // Check if vertically overlapping top of platform while falling
      if (velocityY > 0 && 
          myRect.bottom >= pRect.top && 
          myRect.bottom <= pRect.top + 20 && // Tolerance
          myRect.right > pRect.left + 5 && 
          myRect.left < pRect.right - 5) {
        
        position.y = platform.position.y - size.y;
        velocityY = 0;
        isJumping = false;
        gameRef.updateScore(1); // Score for landing? Or distance? 
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10)), paint);
    
    // Ihram texture (Two pieces)
    final ihramPaint = Paint()..color = Colors.grey[300]!..style = PaintingStyle.stroke..strokeWidth = 2;
    // Lower piece line
    canvas.drawRect(Rect.fromLTWH(0, size.y * 0.6, size.x, 2), ihramPaint);
    // Upper piece drape
    canvas.drawLine(Offset(0, size.y * 0.2), Offset(size.x, size.y * 0.5), ihramPaint);

    // Face
    canvas.drawRect(Rect.fromLTWH(size.x * 0.2, size.y * 0.1, size.x * 0.6, size.y * 0.25), Paint()..color = const Color(0xFFFFCCBC));

    const textStyle = TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'الحاج', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, -15));
  }
}

class Platform extends PositionComponent with HasGameRef<HajjJourneyGame> {
  final double width;
  final double height;
  final String label;

  Platform({required Vector2 position, required this.width, required this.height, required this.label}) 
      : super(position: position, size: Vector2(width, height));

  @override
  void render(Canvas canvas) {
    // Marble/Stone platform
    final paint = Paint()..color = const Color(0xFFEEEEEE); // Grey 200
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)), paint);
    
    // 3D effect border at bottom
    final borderPaint = Paint()..color = Colors.grey[400]!;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, size.y - 5, size.x, 5), const Radius.circular(8)), borderPaint);
    
    // Text Label
    final fontSize = size.y * 0.4;
    final textStyle = TextStyle(color: Colors.brown[800], fontSize: fontSize, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

