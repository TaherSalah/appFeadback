import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class MosqueStackerGame extends BaseEducationalGame with TapCallbacks {
  MosquePiece? currentPiece;
  double gameSpeed = 0; // Set in onResize
  final List<MosquePiece> stackedPieces = [];
  bool isDropping = false;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Elegant mosque interior background
    add(BackgroundGradient(colors: [
      const Color(0xFF004D40), // Teal 900
      const Color(0xFF00796B), // Teal 700
      const Color(0xFF004D40), // Teal 900
    ]));
    
    // Initial spawn will happen after first resize
  }
  
  @override
  void onGameResize(Vector2 size) {
    if (size.x < 100 || size.y < 100) return;
    super.onGameResize(size);
    gameSpeed = size.x * 0.5; // Speed relative to screen width
    
    // If we have a zero-sized piece (bad init), restart.
    if (currentPiece != null && currentPiece!.size.x == 0) {
      restart();
      return;
    }

    // Spawn first piece if not started
    if (currentPiece == null && stackedPieces.isEmpty) {
      spawnNewPiece();
    } else if (currentPiece != null && !isDropping) {
        // Resize current piece dynamically
        final double baseUnit = min(size.x, size.y);
        final pieceSize = Vector2(baseUnit * 0.3, baseUnit * 0.15);
        if (currentPiece!.type == 2) {
             currentPiece!.size = Vector2(pieceSize.x * 0.9, pieceSize.y * 1.2);
        } else {
             currentPiece!.size = pieceSize;
        }
        currentPiece!.movingSpeed = gameSpeed;
    }
  }

  void spawnNewPiece() {
    if (size.x < 100 || size.y < 100) return; // Double check

    isDropping = false;
    final pieceType = stackedPieces.length % 3;
    final double baseUnit = min(size.x, size.y);
    final pieceSize = Vector2(baseUnit * 0.3, baseUnit * 0.15); // Dynamic size
    
    currentPiece = MosquePiece(
      type: pieceType,
      position: Vector2(size.x / 2, size.y * 0.2), // Start from top area
      movingSpeed: gameSpeed,
      size: pieceSize,
    );
    add(currentPiece!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || isDropping || currentPiece == null) return;
    isDropping = true;
    currentPiece!.drop();
  }

  void createLandingParticles(Vector2 pos, Color color) {
    final double baseUnit = min(size.x, size.y);
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, size.y * 0.5),
            speed: Vector2(random.nextDouble() * baseUnit - baseUnit/2, -random.nextDouble() * baseUnit/4),
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

  void onPieceLanded(MosquePiece piece) {
    final colors = [Colors.blueGrey[100]!, Colors.blueGrey[300]!, Colors.amber[400]!];
    final pieceColor = colors[piece.type];

    if (stackedPieces.isEmpty) {
      stackedPieces.add(piece);
      updateScore(10);
      createLandingParticles(piece.position + Vector2(0, piece.size.y), pieceColor);
      spawnNewPiece();
    } else {
      final lastPiece = stackedPieces.last;
      
      // Calculate overlap/offset
      final offset = (piece.position.x - lastPiece.position.x).abs();
      final allowedError = lastPiece.size.x * 0.4; // 40% margin of error
      
      if (offset < allowedError) {
        stackedPieces.add(piece);
        updateScore(20);
        gameSpeed += size.x * 0.02; // Increase speed slightly
        createLandingParticles(piece.position + Vector2(0, piece.size.y), pieceColor);
        spawnNewPiece();
        
        // Scroll down if stack gets too high
        if (stackedPieces.length > 4) {
           final scrollAmount = piece.size.y;
           for (var p in children.whereType<MosquePiece>()) {
             if (stackedPieces.contains(p)) {
                p.position.y += scrollAmount;
             }
           }
           // Remove pieces that go off screen to save memory? 
           // For now keep them for visual stack effect
        }
      } else {
        createLandingParticles(piece.position + piece.size/2, Colors.redAccent);
        gameOver();
      }
    }
  }

  @override
  void restart() {
    super.restart();
    children.whereType<MosquePiece>().forEach((p) => p.removeFromParent());
    stackedPieces.clear();
    currentPiece = null;
    gameSpeed = size.x * 0.5;
    spawnNewPiece();
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
    
    // Arches silhouettes
    final archPaint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.stroke..strokeWidth = gameRef.size.x * 0.02;
    for(int i=0; i<3; i++) {
        final w = gameRef.size.x / 3;
        final x = w * i;
        final path = Path();
        path.moveTo(x, gameRef.size.y);
        path.lineTo(x, gameRef.size.y * 0.2);
        path.quadraticBezierTo(x + w/2, gameRef.size.y * 0.1, x + w, gameRef.size.y * 0.2);
        path.lineTo(x + w, gameRef.size.y);
        canvas.drawPath(path, archPaint);
    }
  }
}

class MosquePiece extends PositionComponent with HasGameRef<MosqueStackerGame> {
  final int type;
  double movingSpeed;
  final bool isStatic; // For pieces already landed? No, we manage state in game
  bool isDropping = false;
  int direction = 1;
  double fallSpeed = 0; // Set in onMount based on screen height

  MosquePiece({required this.type, required Vector2 position, required this.movingSpeed, required Vector2 size}) 
      : isStatic = false, super(position: position, size: size);

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
    fallSpeed = gameRef.size.y * 1.5; // Falls in < 1 second
    
    if (type == 2) { // Dome is slightly smaller naturally
       size = Vector2(size.x * 0.9, size.y * 1.2);
    }
  }

  void drop() {
    isDropping = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) {
        // Stop moving if game over
        return; 
    }
    
    // If it's already landed (part of stack), don't update physics
    if (gameRef.stackedPieces.contains(this)) return;

    if (!isDropping) {
      position.x += movingSpeed * direction * dt;
      if (position.x > gameRef.size.x - size.x/2 || position.x < size.x/2) {
        direction *= -1;
        position.x = position.x.clamp(size.x/2, gameRef.size.x - size.x/2);
      }
    } else {
      position.y += fallSpeed * dt;

      double targetY = gameRef.size.y - size.y/2 - (gameRef.size.y * 0.05); // Bottom padding
      if (gameRef.stackedPieces.isNotEmpty) {
        // Stack on top of last piece. 
        // Note: Anchor is center, so position.y is center of piece.
        // Last piece top edge = lastPiece.y - lastPiece.h/2
        // This piece bottom edge = position.y + size.y/2
        // So targetY center = (LastPiece.y - LastPiece.h/2) - size.y/2
        final last = gameRef.stackedPieces.last;
        targetY = last.position.y - last.size.y/2 - size.y/2;
      }

      if (position.y >= targetY) {
        position.y = targetY;
        isDropping = false;
        gameRef.onPieceLanded(this);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final colors = [Colors.blueGrey[100]!, Colors.blueGrey[300]!, Colors.amber[400]!];
    final paint = Paint()..color = colors[type];
    
    // Marble feel with slight shine
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)), paint);
    
    // Texture logic
    if (type == 0 || type == 1) { // Base or Walls
       // Add marble styling
       final veinPaint = Paint()..color = Colors.black.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1.0;
       canvas.drawLine(Offset(size.x*0.2, size.y*0.2), Offset(size.x*0.4, size.y*0.8), veinPaint);
       canvas.drawLine(Offset(size.x*0.7, size.y*0.1), Offset(size.x*0.5, size.y*0.9), veinPaint);
    }
    
    if (type == 1) { // Detailed Wall (Windows)
      final windowPaint = Paint()..color = Colors.teal[900]!.withOpacity(0.5);
      final w = size.x * 0.2;
      final h = size.y * 0.6;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.x * 0.3, size.y/2), width: w, height: h), Radius.circular(w/2)), windowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.x * 0.7, size.y/2), width: w, height: h), Radius.circular(w/2)), windowPaint);
    } else if (type == 2) { // Dome with highlight
      final path = Path()
        ..moveTo(0, size.y)
        ..quadraticBezierTo(size.x / 2, -size.y * 0.5, size.x, size.y)
        ..close();
      
      // Draw dome shape again to clip or just draw over rect? 
      // Actually rect is base, let's draw dome ON TOP or instead of rect?
      // Since we drew Rect first, let's redraw proper dome shape
      canvas.drawPath(path, paint);
      
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawPath(path, shinePaint);
      
      // Crescent
      canvas.drawCircle(Offset(size.x/2, -size.y*0.2), size.x*0.1, Paint()..color=Colors.amber[600]!);
    }
    
    final labels = ['القاعدة', 'البناء', 'القبة'];
    final fontSize = size.y * 0.3;
    final textStyle = TextStyle(color: Colors.black, fontSize: fontSize, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: labels[type], style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    
    // Center text, but if dome, lower it
    double ty = (size.y - textPainter.height) / 2;
    if (type == 2) ty += size.y * 0.2;
    
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, ty));
  }
}

