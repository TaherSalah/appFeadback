import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class KaabaProtectorGame extends BaseEducationalGame with TapCallbacks, DragCallbacks {
  @override
  String get storageKey => 'kaaba_protector';
  Bird? bird;
  Kaaba? kaaba;
  double spawnTimer = 0;
  final Random random = Random();
  double enemySpeed = 0; // Will be set in onResize
  
  // Game constants as percentages of screen size
  static const double kaabaSizeRatio = 0.15; // 15% of screen width
  static const double birdSizeRatio = 0.12;  // 12% of screen width
  static const double elephantSizeRatio = 0.14; // 14% of screen width
  static const double stoneSizeRatio = 0.04;    // 4% of screen width

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Beautiful desert sunset gradient
    add(BackgroundGradient(colors: [
      const Color(0xFF1A237E), // Deep Blue (Night/Early Dawn)
      const Color(0xFFEF6C00), // Orange (Sunset/Sunrise)
      const Color(0xFFFFD54F), // Light Yellow
    ]));
    
    // Initial setup - correct positions will be set in onGameResize
    kaaba = Kaaba();
    add(kaaba!);

    bird = Bird();
    add(bird!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // update speed based on width
    enemySpeed = size.x * 0.25; // Speed takes 4 seconds to cross screen
    
    // Determine base unit from smaller dimension to maintain aspect ratio logic
    final double baseUnit = min(size.x, size.y);
    
    // Resize Kaaba
    if (kaaba != null && children.contains(kaaba!)) {
      kaaba!.size = Vector2.all(baseUnit * 0.25); 
      kaaba!.position = Vector2(size.x * 0.05, size.y - kaaba!.size.y - (size.y * 0.05)); // 5% padding
    }

    // Resize Bird
    if (bird != null && children.contains(bird!)) {
       bird!.size = Vector2(baseUnit * 0.15, baseUnit * 0.10);
       // Keep Y relative, clamp X
       bird!.position.y = size.y * 0.15; // 15% from top
       bird!.position.x = bird!.position.x.clamp(bird!.size.x/2, size.x - bird!.size.x/2);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    // Spawn faster as score increases
    final double spawnInterval = max(0.8, 2.0 - (score * 0.05));
    
    if (spawnTimer > spawnInterval) {
      spawnElephant();
      spawnTimer = 0;
      enemySpeed += size.x * 0.005; // Slightly increase speed relative to screen
    }
  }

  void spawnElephant() {
    final double baseUnit = min(size.x, size.y);
    final elephantSize = Vector2(baseUnit * 0.18, baseUnit * 0.14);
    
    // Spawn at random intervals but ensure fair gameplay
    // 70% chance ground, 30% chance flying (if we added flying enemies later)
    // For now simple ground logic
    
    final elephant = Elephant(
      position: Vector2(size.x + elephantSize.x, size.y - elephantSize.y - (size.y * 0.05)),
      size: elephantSize,
      speed: enemySpeed,
    );
    add(elephant);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || bird == null) return;
    bird!.dropStone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isGameOver || bird == null) return;
    bird!.position.x += event.localDelta.x;
    bird!.position.x = bird!.position.x.clamp(bird!.size.x / 2, size.x - bird!.size.x / 2);
  }

  void createExplosion(Vector2 pos) {
    final double baseUnit = min(size.x, size.y);
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, size.y * 0.8), // Gravity relative to screen height
            speed: Vector2(
               (random.nextDouble() - 0.5) * baseUnit * 1.5,
               -random.nextDouble() * baseUnit * 1.0
            ),
            position: pos.clone(),
            child: CircleParticle(
              radius: baseUnit * 0.015,
              paint: Paint()..color = Colors.deepOrangeAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
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
    onGameResize(size); // Reset speeds
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
    
    // Drwaing nicer animated-looking dunes
    _drawDunes(canvas, const Color(0xffDEB887).withOpacity(0.3), 1.2, 0.5);
    _drawDunes(canvas, const Color(0xffD2691E).withOpacity(0.5), 0.8, 0.7);
  }

  void _drawDunes(Canvas canvas, Color color, double heightFactor, double complexity) {
    final path = Path();
    path.moveTo(0, gameRef.size.y);
    
    for (double i = 0; i <= gameRef.size.x; i += gameRef.size.x / 20) {
       // Simple sine wave for dunes
       final y = gameRef.size.y - (sin(i * 0.01 * complexity) * 30 * heightFactor) - (gameRef.size.y * 0.15) ;
       path.lineTo(i, y);
    }
    path.lineTo(gameRef.size.x, gameRef.size.y);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

class Kaaba extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  // Size is managed by parent onResize

  @override
  void render(Canvas canvas) {
    // Kaaba Body (Cube)
    final paint = Paint()..color = Colors.black;
    // Add subtle shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4)), 
      paint
    );
    
    // Gold Band (Top)
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final bandHeight = size.y * 0.15;
    final bandTop = size.y * 0.2;
    canvas.drawRect(Rect.fromLTWH(0, bandTop, size.x, bandHeight), goldPaint);
    
    // Calligraphy lines (Simplified simulation)
    final detailPaint = Paint()
      ..color = const Color(0xFFFFA000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    // Decorative pattern loop
    for(double i=0; i<size.x; i+= size.x/6) {
       canvas.drawRect(Rect.fromCenter(
         center: Offset(i + size.x/12, bandTop + bandHeight/2), 
         width: size.x/10, height: bandHeight * 0.6
       ), detailPaint);
    }

    // Door
    final doorPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * 0.65, size.y * 0.55, size.x * 0.25, size.y * 0.45),
        const Radius.circular(2)
      ), 
      doorPaint
    );

    // Text Label below
    // Calculate fontsize based on component size
    final double fontSize = size.y * 0.15;
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [
      Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))
    ]);
    
    final textPainter = TextPainter(
      text: TextSpan(text: 'الكعبة المشرفة', style: textStyle.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.rtl,
    )..layout();
    
    // Draw text centered below the Kaaba, slightly up so it's readable
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y + 5));
  }
}

class Bird extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  // Size managed by parent

  void dropStone() {
    gameRef.add(Stone(
      position: position.clone(),
      size: Vector2(size.x * 0.3, size.x * 0.3) // Stone relative to bird
    ));
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white; // Ababil birds described white/greenish usually
    final path = Path();
    
    // Artistic bird shape
    final w = size.x;
    final h = size.y;
    
    path.moveTo(w * 0.5, h * 0.5); // Body center
    // Left Wing
    path.quadraticBezierTo(w * 0.1, h * 0.1, 0, h * 0.4);
    path.quadraticBezierTo(w * 0.2, h * 0.6, w * 0.4, h * 0.6);
    // Right Wing
    path.quadraticBezierTo(w * 0.9, h * 0.1, w, h * 0.4);
    path.quadraticBezierTo(w * 0.8, h * 0.6, w * 0.6, h * 0.6);
    // Tail
    path.lineTo(w * 0.5, h);
    path.close();

    // Shadow
    canvas.drawPath(path.shift(const Offset(0, 5)), Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(path, paint);
    
    // Label
    final double fontSize = w * 0.18;
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [
       Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))
    ]);
    final textPainter = TextPainter(
      text: TextSpan(text: 'أبابيل', style: textStyle.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((w - textPainter.width) / 2, -textPainter.height));
  }
}

class Elephant extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  final double speed;

  Elephant({required Vector2 position, required Vector2 size, required this.speed}) 
      : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    position.x -= speed * dt;

    // Check collision with Kaaba
    if (gameRef.kaaba != null && position.x < gameRef.kaaba!.position.x + gameRef.kaaba!.size.x * 0.5) {
      gameRef.createExplosion(position + size/2);
      gameRef.gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey[700]!;
    
    // Main Body
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y * 0.8), 
      const Radius.circular(8)
    ), paint);
    
    // Head
    canvas.drawCircle(Offset(size.x * 0.2, size.y * 0.4), size.y * 0.35, paint);
    
    // Trunk
    final trunkPath = Path();
    trunkPath.moveTo(size.x * 0.1, size.y * 0.5);
    trunkPath.quadraticBezierTo(size.x * 0.0, size.y * 0.9, size.x * 0.2, size.y * 0.8);
    final trunkPaint = Paint()..color = Colors.grey[700]!..style = PaintingStyle.stroke ..strokeWidth = size.x * 0.08..strokeCap = StrokeCap.round;
    canvas.drawPath(trunkPath, trunkPaint);

    // Legs
    final legPaint = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTWH(size.x * 0.15, size.y * 0.7, size.x * 0.15, size.y * 0.3), legPaint);
     canvas.drawRect(Rect.fromLTWH(size.x * 0.65, size.y * 0.7, size.x * 0.15, size.y * 0.3), legPaint);

    // Label
    final double fontSize = size.x * 0.15;
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [
      Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))
    ]);
    final textPainter = TextPainter(
      text: TextSpan(text: 'فيل أبرهة', style: textStyle.copyWith(fontSize: fontSize)),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, size.y * 0.3));
  }
}

class Stone extends PositionComponent with HasGameRef<KaabaProtectorGame> {
  double fallSpeed = 0;

  Stone({required Vector2 position, required Vector2 size}) : super(position: position, size: size);

  @override
  void onMount() {
    super.onMount();
    fallSpeed = gameRef.size.y * 0.8; // Fall logic relative to screen height
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;

    for (final elephant in gameRef.children.whereType<Elephant>()) {
      if (Rect.fromLTWH(position.x, position.y, size.x, size.y).overlaps(Rect.fromLTWH(elephant.position.x, elephant.position.y, elephant.size.x, elephant.size.y))) {
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
    // Glowing stone (Baked clay effect)
    final glowPaint = Paint()..color = Colors.orangeAccent.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.6, glowPaint);

    final paint = Paint()..color = const Color(0xff8D6E63); // Brownish clay color
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    
    // Label details disabled for stone to reduce clutter/performance cost as they are small and many
  }
}


