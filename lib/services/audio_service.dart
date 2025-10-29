import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _musicPlayer = AudioPlayer();

  static bool _soundEnabled = true;
  static bool _musicEnabled = true;

  static Future<void> initialize() async {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static void playSound(String soundName) {
    if (!_soundEnabled) return;

    // For now, we'll use system sounds via haptic feedback
    // In production, load actual audio files from assets
    try {
      // _sfxPlayer.play(AssetSource('audio/$soundName.mp3'));
    } catch (e) {
      // Silently fail if audio file not found
    }
  }

  static void playMusic(String musicName) {
    if (!_musicEnabled) return;

    try {
      // _musicPlayer.play(AssetSource('audio/$musicName.mp3'));
    } catch (e) {
      // Silently fail if audio file not found
    }
  }

  static void stopMusic() {
    _musicPlayer.stop();
  }

  static void pauseMusic() {
    _musicPlayer.pause();
  }

  static void resumeMusic() {
    _musicPlayer.resume();
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  static bool get soundEnabled => _soundEnabled;
  static bool get musicEnabled => _musicEnabled;

  static void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
