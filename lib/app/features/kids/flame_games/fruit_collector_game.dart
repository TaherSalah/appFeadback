import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class FruitCollectorGame extends BaseEducationalGame with DragCallbacks {
  @override
  String get storageKey => 'fruit_collector';
  Player? player;
  double spawnTimer = 0;
  final Random random = Random();

  final List<String> halalEmojis = [
    '🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🍈',
    '🍒','🍑','🥭','🍍','🥥','🥝','🍅','🥑',
    '🍆','🥕','🌽','🌶️','🥒','🥬','🥦','🧄','🧅',
    '🥔','🍠','🥜','🌰'
  ];
  final List<String> haramEmojis = ['🦗', '🐜', '🕷️', '🦂', '🐍'];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(BackgroundGradient(level: level));

    player = Player();
    add(player!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (player != null && children.contains(player!)) {
      final double baseUnit = min(size.x, size.y);
      final bool isTablet = size.x > 600;
      
      if (isTablet) {
        player!.size = Vector2(baseUnit * 0.25, baseUnit * 0.15);
      } else {
        // سلة أكبر في الموبايل
        player!.size = Vector2(baseUnit * 0.35, baseUnit * 0.21);
      }
      
      player!.position =
          Vector2(player!.position.x, size.y - player!.size.y - 20);
      player!.position.x = player!.position.x
          .clamp(player!.size.x * 0.05, size.x - player!.size.x * 1.05);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // Level up logic every 20 points
    if (score >= level * 10) {
      level++;
      levelNotifier.value = level;
      onLevelUpdate?.call(level);

      // Update background level
      final bg = children.whereType<BackgroundGradient>().firstOrNull;
      if (bg != null) {
        bg.level = level;
      }

      // Level Up Feedback
      add(LevelUpText(level: level, position: size / 2));
    }

    spawnTimer += dt;
    // Speed and interval now depend on level
    final spawnInterval = max(0.4, 1.1 - (level * 0.1) - (score * 0.005));

    if (spawnTimer > spawnInterval) {
      spawnItem();
      spawnTimer = 0;
    }
  }

  void spawnItem() {
    final isHalal = random.nextDouble() > 0.3; // 70% chance for halal
    final emoji = isHalal
        ? halalEmojis[random.nextInt(halalEmojis.length)]
        : haramEmojis[random.nextInt(haramEmojis.length)];

    final double baseUnit = min(size.x, size.y);
    final bool isTablet = size.x > 600;
    final itemSize = Vector2.all(baseUnit * (isTablet ? 0.12 : 0.18));

    final item = GameItem(
      isHalal: isHalal,
      emoji: emoji,
      position: Vector2(
          random.nextDouble() * (size.x - itemSize.x) + itemSize.x / 2,
          -itemSize.y),
      size: itemSize,
      speed: size.y * (0.2 + (level * 0.05)) + (score * 2),
    );
    add(item);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || player == null) return;
    player!.position.x += event.localDelta.x;
    player!.position.x = player!.position.x
        .clamp(player!.size.x * 0.05, size.x - player!.size.x * 1.05);
  }

  @override
  void restart() {
    super.restart();
    children.whereType<GameItem>().forEach((item) => item.removeFromParent());
    children.whereType<LevelUpText>().forEach((txt) => txt.removeFromParent());

    final bg = children.whereType<BackgroundGradient>().firstOrNull;
    if (bg != null) bg.level = 1;

    onGameResize(size);
  }
}

class LevelUpText extends PositionComponent with HasGameRef {
  final int level;
  double opacity = 1.0;
  double lifeTime = 0;

  LevelUpText({required this.level, required Vector2 position})
      : super(position: position, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    position.y -= 40 * dt;
    if (lifeTime > 1.0) {
      opacity -= dt * 2;
    }
    if (opacity <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'المستوى الجديد: $level',
        style: TextStyle(
          fontSize: 35,
          fontFamily: 'me',
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(opacity.clamp(0, 1)),
          shadows: [
            Shadow(
                blurRadius: 10,
                color: Colors.blueAccent.withOpacity(opacity.clamp(0, 1)))
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
  }
}

class BackgroundGradient extends Component with HasGameRef {
  int _prevLevel = -1;
  int level;
  BackgroundGradient({required this.level});

  final List<List<Color>> levelColors = [
    [const Color(0xFFE0F7FA), const Color(0xFF80DEEA), const Color(0xFF4DD0E1)],
    [const Color(0xFFF1F8E9), const Color(0xFFC5E1A5), const Color(0xFF9CCC65)],
    [const Color(0xFFFFF9C4), const Color(0xFFFFF176), const Color(0xFFFFEB3B)],
    [const Color(0xFFF3E5F5), const Color(0xFFCE93D8), const Color(0xFFBA68C8)],
    [const Color(0xFFFFE0B2), const Color(0xFFFFB74D), const Color(0xFFFFA726)],
  ];

  final Paint _paint = Paint();
  final Paint _decorPaint = Paint()..color = Colors.white.withOpacity(0.3);
  final Paint _rayPaint = Paint()..color = Colors.white.withOpacity(0.1);
  final Path _rayPath = Path();

  void _updateShader() {
    final colorIdx = (level - 1) % levelColors.length;
    _paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: levelColors[colorIdx],
    ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y));
    
    _rayPath.reset();
    _rayPath.moveTo(0, 0);
    _rayPath.lineTo(gameRef.size.x * 0.4, gameRef.size.y);
    _rayPath.lineTo(gameRef.size.x * 0.6, gameRef.size.y);
    _rayPath.lineTo(gameRef.size.x * 0.2, 0);
    _rayPath.close();
    
    _prevLevel = level;
  }

  @override
  void render(Canvas canvas) {
    if (level != _prevLevel) _updateShader();
    canvas.drawRect(Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y), _paint);
    canvas.drawCircle(Offset(gameRef.size.x * 0.8, gameRef.size.y * 0.2), gameRef.size.x * 0.1, _decorPaint);
    canvas.drawCircle(Offset(gameRef.size.x * 0.2, gameRef.size.y * 0.6), gameRef.size.x * 0.15, _decorPaint);
    canvas.drawPath(_rayPath, _rayPaint);
  }
}

class Player extends PositionComponent with HasGameRef<FruitCollectorGame> {
  double glowIntensity = 0;
  
  final Paint _handlePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _bodyPaint = Paint();
  final Paint _rimPaint = Paint()..color = const Color(0xFF5D4037);
  final Paint _shinePaint = Paint()..color = Colors.white.withOpacity(0.15);
  final Paint _texturePaint = Paint()
    ..color = const Color(0xFF4E342E).withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint _glowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
  final Path _bodyPath = Path();
  
  TextPainter? _textPainter;

  void triggerCatchGlow() {
    glowIntensity = 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (glowIntensity > 0) {
      glowIntensity -= dt * 2;
    }
  }

  void _rebuildCache() {
    final double w = size.x;
    final double h = size.y;
    
    _handlePaint.color = const Color(0xFF6D4C41);
    _handlePaint.strokeWidth = w * 0.08;
    
    _bodyPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    _bodyPath.reset();
    _bodyPath.moveTo(0, 0);
    _bodyPath.cubicTo(w * 0.05, h * 0.9, w * 0.95, h * 0.9, w, 0);
    _bodyPath.close();

    _textPainter = TextPainter(
      text: TextSpan(
        text: '',
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          fontFamily: "me",
          fontSize: w * 0.15,
          shadows: const [Shadow(blurRadius: 3, color: Colors.black45, offset: Offset(1, 1))]
        )
      ),
      textDirection: TextDirection.rtl,
    )..layout();
  }

  Vector2? _lastSize;

  @override
  void render(Canvas canvas) {
    if (_textPainter == null || _lastSize != size) {
      _lastSize = size.clone();
      _rebuildCache();
    }
    final double w = size.x;
    final double h = size.y;

    // Handle
    canvas.drawArc(Rect.fromLTWH(w * 0.1, -h * 0.4, w * 0.8, h * 0.8), pi, pi, false, _handlePaint);

    // Glow
    if (glowIntensity > 0) {
      _glowPaint.color = Colors.white.withOpacity(glowIntensity * 0.4);
      canvas.drawRect(Rect.fromLTWH(-10, -5, w + 20, h * 0.3), _glowPaint);
    }

    // Body
    canvas.drawPath(_bodyPath, _bodyPaint);
    
    canvas.save();
    canvas.clipPath(_bodyPath);
    // Texture
    for (double i = w * 0.1; i < w; i += w * 0.15) {
      canvas.drawLine(Offset(i, 0), Offset(i.clamp(w * 0.05, w * 0.95), h * 0.7), _texturePaint);
    }
    for (double j = h * 0.2; j < h * 0.8; j += h * 0.2) {
      canvas.drawArc(Rect.fromLTWH(0, -j, w, j * 2), 0.2, pi - 0.4, false, _texturePaint);
    }
    canvas.restore();

    // Rim
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-w * 0.05, 0, w * 1.1, h * 0.15), Radius.circular(h * 0.1)), _rimPaint);
    canvas.drawRect(Rect.fromLTWH(-w * 0.02, h * 0.02, w * 1.04, h * 0.04), _shinePaint);

    _textPainter?.paint(canvas, Offset((w - _textPainter!.width) / 2, h * 0.35));
  }
}

class GameItem extends PositionComponent with HasGameRef<FruitCollectorGame> {
  final bool isHalal;
  final String emoji;
  final double speed;

  final Paint _paint = Paint();
  final Paint _highlightPaint = Paint()..color = Colors.white.withOpacity(0.4);
  TextPainter? _textPainter;
  TextPainter? _labelPainter;

  GameItem({required this.isHalal, required this.emoji, required Vector2 position, required Vector2 size, required this.speed}) 
      : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.y += speed * dt;

    if (gameRef.player != null) {
      final player = gameRef.player!;
      final itemCenter = position + size / 2;
      final bool withinVerticalRange = (itemCenter.y >= player.position.y - 10) && (itemCenter.y <= player.position.y + player.size.y * 0.3);
      final bool withinHorizontalRange = (itemCenter.x >= player.position.x + player.size.x * 0.1) && (itemCenter.x <= player.position.x + player.size.x * 0.9);

      if (withinVerticalRange && withinHorizontalRange) {
        if (isHalal) {
          gameRef.updateScore(1);
          player.triggerCatchGlow();
        } else {
          gameRef.gameOver();
        }
        removeFromParent();
      }
    }

    if (position.y > gameRef.size.y) removeFromParent();
  }

  void _rebuildCache() {
    _paint.color = isHalal ? Colors.green : Colors.red;
    _textPainter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size.x * 0.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    _labelPainter = TextPainter(
      text: TextSpan(text: isHalal ? 'حلال' : 'حرام', style: TextStyle(color: Colors.white, fontSize: size.x * 0.25, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 2)])),
      textDirection: TextDirection.rtl,
    )..layout();
  }

  Vector2? _lastSize;

  @override
  void render(Canvas canvas) {
    if (_textPainter == null || _lastSize != size) {
      _lastSize = size.clone();
      _rebuildCache();
    }
    
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
    canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.35), size.x * 0.1, _highlightPaint);
    _textPainter?.paint(canvas, Offset((size.x - _textPainter!.width) / 2, (size.y - _textPainter!.height) / 2));
    _labelPainter?.paint(canvas, Offset((size.x - _labelPainter!.width) / 2, size.y / 2 + size.y * 0.15));
  }
}
