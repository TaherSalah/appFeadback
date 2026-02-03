import 'package:flame/game.dart';
import 'package:flutter/material.dart';

abstract class BaseEducationalGame extends FlameGame {
  int score = 0;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  bool isGameOver = false;
  double elapsedTime = 0;
  
  Function(int)? onScoreUpdate;
  VoidCallback? onGameOver;

  BaseEducationalGame({this.onScoreUpdate, this.onGameOver});

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameOver) {
      elapsedTime += dt;
    }
  }

  void updateScore(int amount) {
    score += amount;
    scoreNotifier.value = score;
    onScoreUpdate?.call(score);
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();
    onGameOver?.call();
    overlays.add('GameOver');
  }

  void restart() {
    score = 0;
    scoreNotifier.value = 0;
    isGameOver = false;
    elapsedTime = 0;
    resumeEngine();
  }
}
