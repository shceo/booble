import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/game_element.dart';
import '../models/game_state.dart';
import '../models/laser_beam.dart';
import '../models/level.dart';
import 'laser_physics.dart';
import 'audio_service.dart';

class GameController extends ChangeNotifier {
  GameState _state;
  Timer? _gameTimer;
  List<LaserPath> _currentLaserPaths = [];

  GameController({required Level level})
      : _state = GameState(
          level: level,
          currentElements: List.from(level.elements),
          status: GameStatus.ready,
        );

  GameState get state => _state;
  List<LaserPath> get laserPaths => _currentLaserPaths;

  void startLevel() {
    _state = _state.copyWith(
      status: GameStatus.playing,
      rotationCount: 0,
      elapsedSeconds: 0,
      activatedTargets: {},
      moveHistory: [],
    );
    _startTimer();
    _updateLaserPaths();
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.status == GameStatus.playing) {
        _state = _state.copyWith(
          elapsedSeconds: _state.elapsedSeconds + 1,
          powerUpCooldown: _state.powerUpCooldown > 0
              ? _state.powerUpCooldown - 1
              : 0,
        );

        // Check time limit
        if (_state.level.constraints.maxTime != null &&
            _state.elapsedSeconds >= _state.level.constraints.maxTime!) {
          _handleTimeUp();
        }

        notifyListeners();
      }
    });
  }

  void _handleTimeUp() {
    _gameTimer?.cancel();
    // Game over logic could be added here
    // For now, just continue playing but no stars
  }

  void rotateElement(Position position) {
    if (_state.status != GameStatus.playing) return;

    final elementIndex = _state.currentElements.indexWhere(
      (e) => e.position == position,
    );

    if (elementIndex == -1) return;

    final element = _state.currentElements[elementIndex];

    // Check if element can be rotated
    if (element.isFixed) {
      AudioService.playSound('error');
      HapticFeedback.lightImpact();
      return;
    }

    bool rotated = false;

    if (element is Mirror) {
      element.rotate();
      rotated = true;
    } else if (element is Splitter) {
      element.rotate();
      rotated = true;
    } else if (element is ColorFilter) {
      element.rotate();
      rotated = true;
    }

    if (rotated) {
      // Check rotation limit
      if (_state.level.constraints.maxRotations != null &&
          _state.rotationCount >= _state.level.constraints.maxRotations!) {
        AudioService.playSound('error');
        HapticFeedback.mediumImpact();
        return;
      }

      _state = _state.copyWith(
        rotationCount: _state.rotationCount + 1,
        moveHistory: [
          ..._state.moveHistory,
          GameMove(
            position: position,
            timestamp: _state.elapsedSeconds,
            action: 'rotate',
          ),
        ],
      );

      AudioService.playSound('rotate');
      HapticFeedback.lightImpact();

      _updateLaserPaths();
      _checkWinCondition();
      notifyListeners();
    }
  }

  void _updateLaserPaths() {
    _currentLaserPaths = LaserPhysics.traceLasers(_state.currentElements);

    // Find activated targets
    final activated = LaserPhysics.findActivatedTargets(
      _currentLaserPaths,
      _state.currentElements,
    );

    _state = _state.copyWith(activatedTargets: activated);
  }

  void _checkWinCondition() {
    if (_state.isCompleted && _state.status == GameStatus.playing) {
      _state = _state.copyWith(status: GameStatus.won);
      _gameTimer?.cancel();
      AudioService.playSound('win');
      HapticFeedback.heavyImpact();
    }
  }

  void usePowerUp() {
    if (!_state.canUsePowerUp) return;

    _state = _state.copyWith(
      isPowerUpActive: true,
      moveHistory: [
        ..._state.moveHistory,
        GameMove(
          position: Position(-1, -1),
          timestamp: _state.elapsedSeconds,
          action: 'powerup',
        ),
      ],
    );

    AudioService.playSound('powerup');
    HapticFeedback.mediumImpact();

    // Show trajectory for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _state = _state.copyWith(
        isPowerUpActive: false,
        powerUpCooldown: 30, // 30 seconds cooldown
      );
      notifyListeners();
    });

    notifyListeners();
  }

  void resetLevel() {
    _gameTimer?.cancel();
    _state = GameState(
      level: _state.level,
      currentElements: List.from(_state.level.elements),
      status: GameStatus.ready,
    );
    _currentLaserPaths = [];
    notifyListeners();
  }

  void pauseGame() {
    if (_state.status == GameStatus.playing) {
      _state = _state.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state.status == GameStatus.paused) {
      _state = _state.copyWith(status: GameStatus.playing);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
