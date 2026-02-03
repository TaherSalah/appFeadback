import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class FruitCollectorGame extends BaseEducationalGame with DragCallbacks {
  late Player player;
  double spawnTimer = 0;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Add a beautiful gradient background
    add(BackgroundGradient(colors: [Colors.green[50]!, Colors.blue[50]!]));
    
    player = Player();
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer > 1.0) {
      spawnItem();
      spawnTimer = 0;
    }
  }

  void spawnItem() {
    final isHalal = random.nextBool();
    final item = GameItem(
      isHalal: isHalal,
      position: Vector2(random.nextDouble() * (size.x - 60) + 30, -50),
    );
    add(item);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver) return;
    player.position.x += event.localDelta.x;
    player.position.x = player.position.x.clamp(40, size.x - 40);
  }

  @override
  void restart() {
    super.restart();
    children.whereType<GameItem>().forEach((item) => item.removeFromParent());
    player.position = Vector2(size.x / 2, size.y - 120);
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
    
    // Abstract shapes for texture
    final decorPaint = Paint()..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(Offset(gameRef.size.x * 0.8, 100), 50, decorPaint);
    canvas.drawCircle(Offset(gameRef.size.x * 0.2, 300), 80, decorPaint);
  }
}

class Player extends PositionComponent with HasGameRef<FruitCollectorGame> {
  Player() : super(size: Vector2(100, 60));

  @override
  void onMount() {
    super.onMount();
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 120);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    // Elegant basket design
    final paint = Paint()..color = Colors.brown[400]!;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.x, 0)
      ..lineTo(size.x * 0.8, size.y)
      ..lineTo(size.x * 0.2, size.y)
      ..close();
    canvas.drawPath(path, paint);
    
    // Weaving lines
    final linePaint = Paint()..color = Colors.brown[600]!..style = PaintingStyle.stroke..strokeWidth = 2;
    for (double i = 10; i < size.x; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.y), linePaint);
    }

    const textStyle = TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: const TextSpan(text: 'سلة الخيرات', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}

class GameItem extends PositionComponent with HasGameRef<FruitCollectorGame> {
  final bool isHalal;
  double speed = 200;

  GameItem({required this.isHalal, required Vector2 position}) 
      : super(position: position, size: Vector2(50, 50));

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.y += speed * dt;

    if (position.distanceTo(gameRef.player.position) < 50) {
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
    final color = isHalal ? Colors.greenAccent : Colors.redAccent;
    
    // Glow effect
    final glowPaint = Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 + 5, glowPaint);

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    const textStyle = TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: isHalal ? 'حلال' : 'حرام', style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
