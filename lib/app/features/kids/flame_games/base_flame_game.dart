import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseEducationalGame extends FlameGame {
  int score = 0;
  int level = 1;
  int highScore = 0;
  bool isNewHighScore = false;
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier<int>(0);
  
  bool isGameOver = false;
  double elapsedTime = 0;
  
  Function(int)? onScoreUpdate;
  Function(int)? onLevelUpdate;
  VoidCallback? onGameOver;

  BaseEducationalGame({this.onScoreUpdate, this.onGameOver});

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;
  }

  /// Unique key for storing the high score of this game
  String get storageKey;

  @override
  Future<void> onLoad() async {
    await loadHighScore();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score_$storageKey') ?? 0;
    highScoreNotifier.value = highScore;
  }

  Future<void> saveHighScore() async {
    if (score > highScore) {
      highScore = score;
      isNewHighScore = true;
      highScoreNotifier.value = highScore;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score_$storageKey', highScore);
    }
  }

  void updateScore(int points) {
    score += points;
    scoreNotifier.value = score;
    onScoreUpdate?.call(score);
    if (score > highScore) {
      saveHighScore();
    }
  }

  void gameOver() {
    isGameOver = true;
    saveHighScore();
    pauseEngine();
    overlays.add('GameOver');
    onGameOver?.call();
  }

  void restart() {
    score = 0;
    level = 1;
    isNewHighScore = false;
    scoreNotifier.value = 0;
    levelNotifier.value = 1;
    isGameOver = false;
    elapsedTime = 0;
    resumeEngine();
  }
}
