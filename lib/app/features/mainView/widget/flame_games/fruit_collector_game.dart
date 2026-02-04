import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class FruitCollectorGame extends BaseEducationalGame with DragCallbacks {
  Player? player;
  double spawnTimer = 0;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Add a beautiful gradient background
    add(BackgroundGradient(colors: [
      const Color(0xFFE0F7FA), // Light Cyan
      const Color(0xFF80DEEA), // Cyan 200
      const Color(0xFF4DD0E1), // Cyan 300
    ]));
    
    player = Player();
    add(player!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Resize Player
    if (player != null && children.contains(player!)) {
      final double baseUnit = min(size.x, size.y);
      player!.size = Vector2(baseUnit * 0.25, baseUnit * 0.15); // Dynamic size
      player!.position = Vector2(player!.position.x, size.y - player!.size.y - 20);
      player!.position.x = player!.position.x.clamp(player!.size.x/2, size.x - player!.size.x/2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    // Increase difficulty over time
    final spawnInterval = max(0.5, 1.0 - (score * 0.02));
    
    if (spawnTimer > spawnInterval) {
      spawnItem();
      spawnTimer = 0;
    }
  }

  void spawnItem() {
    final isHalal = random.nextBool();
    final double baseUnit = min(size.x, size.y);
    final itemSize = Vector2.all(baseUnit * 0.12);
    
    final item = GameItem(
      isHalal: isHalal,
      position: Vector2(
        random.nextDouble() * (size.x - itemSize.x) + itemSize.x/2, 
        -itemSize.y
      ),
      size: itemSize,
      speed: size.y * 0.3 + (score * 5), // Speed relative to screen height
    );
    add(item);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || player == null) return;
    player!.position.x += event.localDelta.x;
    player!.position.x = player!.position.x.clamp(player!.size.x/2, size.x - player!.size.x/2);
  }

  @override
  void restart() {
    super.restart();
    children.whereType<GameItem>().forEach((item) => item.removeFromParent());
    onGameResize(size); // Reset positions
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
    
    // Abstract shapes for texture - modernized
    final decorPaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(gameRef.size.x * 0.8, gameRef.size.y * 0.2), gameRef.size.x * 0.1, decorPaint);
    canvas.drawCircle(Offset(gameRef.size.x * 0.2, gameRef.size.y * 0.6), gameRef.size.x * 0.15, decorPaint);
    
    // Subtle ray
    final rayPaint = Paint()..color = Colors.white.withOpacity(0.1);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(gameRef.size.x * 0.4, gameRef.size.y);
    path.lineTo(gameRef.size.x * 0.6, gameRef.size.y);
    path.lineTo(gameRef.size.x * 0.2, 0);
    path.close();
    canvas.drawPath(path, rayPaint);
  }
}

class Player extends PositionComponent with HasGameRef<FruitCollectorGame> {
  // Size managed by parent

  @override
  void render(Canvas canvas) {
    // Elegant basket design
    final paint = Paint()..color = const Color(0xFF8D6E63); // Brown 400
    
    // Basket shape
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(0, size.y * 0.8, size.x, size.y * 0.8, size.x, 0) // Curved bottom
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Rim
    canvas.drawRect(Rect.fromLTWH(-5, 0, size.x + 10, size.y * 0.15), Paint()..color = const Color(0xFF6D4C41));
    
    // Pattern
    final linePaint = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (double i = size.x * 0.2; i < size.x * 0.9; i += size.x * 0.2) {
       canvas.drawLine(Offset(i, size.y * 0.1), Offset(i, size.y * 0.7), linePaint);
    }

    // Label
    final fontSize = size.x * 0.15;
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black26)]);
    final textPainter = TextPainter(
      text: TextSpan(text: 'سلة الخيرات', style: textStyle.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y * 0.3));
  }
}

class GameItem extends PositionComponent with HasGameRef<FruitCollectorGame> {
  final bool isHalal;
  final double speed;

  GameItem({required this.isHalal, required Vector2 position, required Vector2 size, required this.speed}) 
      : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.y += speed * dt;

    if (gameRef.player != null && position.distanceTo(gameRef.player!.position + gameRef.player!.size/2) < (size.x + gameRef.player!.size.x)/3) {
      if (isHalal) {
        gameRef.updateScore(1);
      } else {
        gameRef.gameOver();
      }
      removeFromParent();
    }

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isHalal ? Colors.green : Colors.red;
    
    // Fruit/Item shape (Simple circle with leaf for fruit)
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    // Highlight
    canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.35), size.x * 0.1, Paint()..color = Colors.white.withOpacity(0.4));
    
    // Label using Emoji for better visuals
    final fontSize = size.x * 0.4; // Large emoji
    final textPainter = TextPainter(
      text: TextSpan(text: isHalal ? '🍏' : '🦗', style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
    
    // Text label below
    final labelSize = size.x * 0.25;
     final labelPainter = TextPainter(
      text: TextSpan(text: isHalal ? 'حلال' : 'حرام', style: TextStyle(color: Colors.white, fontSize: labelSize, fontWeight: FontWeight.bold, shadows: [const Shadow(blurRadius: 2)])),
      textDirection: TextDirection.rtl,
    )..layout();
    labelPainter.paint(canvas, Offset((size.x - labelPainter.width) / 2, size.y / 2 + size.y * 0.1));
  }
}

