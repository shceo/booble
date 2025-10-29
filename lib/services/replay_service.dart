import 'dart:async';
import 'package:flutter/material.dart';

import '../models/game_element.dart';
import '../models/game_state.dart';

class ReplayService {
  final List<GameMove> _moves;
  int _currentMoveIndex = 0;
  Timer? _playbackTimer;

  ReplayService(this._moves);

  bool get hasMoreMoves => _currentMoveIndex < _moves.length;
  int get currentIndex => _currentMoveIndex;
  int get totalMoves => _moves.length;

  void startPlayback({
    required Function(Position) onRotate,
    required VoidCallback onComplete,
  }) {
    _currentMoveIndex = 0;
    _playbackTimer?.cancel();

    if (_moves.isEmpty) {
      onComplete();
      return;
    }

    // Play moves based on timestamps
    _playNextMove(onRotate, onComplete);
  }

  void _playNextMove(
    Function(Position) onRotate,
    VoidCallback onComplete,
  ) {
    if (_currentMoveIndex >= _moves.length) {
      onComplete();
      return;
    }

    final move = _moves[_currentMoveIndex];

    if (move.action == 'rotate') {
      onRotate(move.position);
    }

    _currentMoveIndex++;

    // Calculate delay to next move
    if (_currentMoveIndex < _moves.length) {
      final nextMove = _moves[_currentMoveIndex];
      final delay = nextMove.timestamp - move.timestamp;

      _playbackTimer = Timer(
        Duration(seconds: delay),
        () => _playNextMove(onRotate, onComplete),
      );
    } else {
      onComplete();
    }
  }

  void stopPlayback() {
    _playbackTimer?.cancel();
    _currentMoveIndex = 0;
  }

  void dispose() {
    _playbackTimer?.cancel();
  }
}

class GhostSolution {
  final List<GameMove> moves;
  final int totalTime;
  final int totalRotations;
  final int stars;

  GhostSolution({
    required this.moves,
    required this.totalTime,
    required this.totalRotations,
    required this.stars,
  });

  static GhostSolution? fromProgress(
    dynamic progress,
  ) {
    if (progress == null || progress.bestReplay == null) {
      return null;
    }

    return GhostSolution(
      moves: progress.bestReplay!,
      totalTime: progress.bestTime,
      totalRotations: progress.bestRotations,
      stars: progress.stars,
    );
  }
}
