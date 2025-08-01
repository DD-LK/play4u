import 'package:flutter/foundation.dart';
import 'package:local_audio_scan/local_audio_scan.dart';

class PlayerStateModel extends ChangeNotifier {
  AudioTrack? _currentTrack;
  bool _isPlaying = false;

  AudioTrack? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;

  void setCurrentTrack(AudioTrack track) {
    _currentTrack = track;
    notifyListeners();
  }

  void setIsPlaying(bool isPlaying) {
    _isPlaying = isPlaying;
    notifyListeners();
  }
}
