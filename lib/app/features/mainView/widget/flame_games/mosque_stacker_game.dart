import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'base_flame_game.dart';

class MosqueStackerGame extends BaseEducationalGame with TapCallbacks {
  late MosquePiece currentPiece;
  double gameSpeed = 200;
  final List<MosquePiece> stackedPieces = [];
  bool isDropping = false;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    // Elegant mosque interior background
    add(BackgroundGradient(colors: [Colors.teal[900]!, Colors.teal[700]!, Colors.teal[900]!]));
    
    spawnNewPiece();
  }

  void spawnNewPiece() {
    isDropping = false;
    final pieceType = stackedPieces.length % 3;
    currentPiece = MosquePiece(
      type: pieceType,
      position: Vector2(size.x / 2, 150),
      movingSpeed: gameSpeed,
    );
    add(currentPiece);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver || isDropping) return;
    isDropping = true;
    currentPiece.drop();
  }

  void createLandingParticles(Vector2 pos, Color color) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(random.nextDouble() * 400 - 200, -random.nextDouble() * 100),
            position: pos.clone(),
            child: CircleParticle(
              radius: 3,
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
      createLandingParticles(piece.position + Vector2(0, 30), pieceColor);
      spawnNewPiece();
    } else {
      final lastPiece = stackedPieces.last;
      final offset = (piece.position.x - lastPiece.position.x).abs();
      
      if (offset < 40) {
        stackedPieces.add(piece);
        updateScore(20);
        gameSpeed += 10;
        createLandingParticles(piece.position + Vector2(0, 30), pieceColor);
        spawnNewPiece();
        
        if (stackedPieces.length > 5) {
          for (var p in children.whereType<MosquePiece>()) {
            p.position.y += 60;
          }
        }
      } else {
        createLandingParticles(piece.position, Colors.redAccent);
        gameOver();
      }
    }
  }

  @override
  void restart() {
    super.restart();
    children.whereType<MosquePiece>().forEach((p) => p.removeFromParent());
    stackedPieces.clear();
    gameSpeed = 200;
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
    final archPaint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.stroke..strokeWidth = 10;
    for(int i=0; i<3; i++) {
       canvas.drawRect(Rect.fromLTWH(gameRef.size.x * (i/3), 0, gameRef.size.x / 3, gameRef.size.y), archPaint);
    }
  }
}

class MosquePiece extends PositionComponent with HasGameRef<MosqueStackerGame> {
  final int type;
  double movingSpeed;
  bool isDropping = false;
  int direction = 1;
  double fallSpeed = 500;

  MosquePiece({required this.type, required Vector2 position, required this.movingSpeed}) 
      : super(position: position, size: Vector2(120, 60));

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
    if (type == 2) size = Vector2(100, 70); 
  }

  void drop() {
    isDropping = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    if (!isDropping) {
      position.x += movingSpeed * direction * dt;
      if (position.x > gameRef.size.x - 60 || position.x < 60) {
        direction *= -1;
      }
    } else {
      position.y += fallSpeed * dt;

      double targetY = gameRef.size.y - 60;
      if (gameRef.stackedPieces.isNotEmpty) {
        targetY = gameRef.stackedPieces.last.position.y - 60;
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
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)), paint);
    
    if (type == 1) { // Detailed Wall
      final windowPaint = Paint()..color = Colors.teal[900]!.withOpacity(0.5);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30, 10, 20, 30), const Radius.circular(10)), windowPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(70, 10, 20, 30), const Radius.circular(10)), windowPaint);
    } else if (type == 2) { // Dome with highlight
      final path = Path()
        ..moveTo(0, size.y)
        ..quadraticBezierTo(size.x / 2, -30, size.x, size.y)
        ..close();
      canvas.drawPath(path, paint);
      
      final shinePaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3;
      canvas.drawPath(path, shinePaint);
    }
    
    final labels = ['القاعدة', 'البناء', 'القبة'];
    const textStyle = TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: labels[type], style: textStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }
}
