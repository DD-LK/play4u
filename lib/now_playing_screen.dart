import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    final playerState = Provider.of<PlayerStateModel>(context, listen: false);
    if (playerState.currentTrack != null) {
      _audioPlayer.play(DeviceFileSource(playerState.currentTrack!.filePath));
    }

    _audioPlayer.onDurationChanged.listen((d) {
      if(mounted) {
        setState(() {
        _duration = d;
      });
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if(mounted) {
        setState(() {
        _position = p;
      });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerStateModel>(
      builder: (context, playerState, child) {
        if (playerState.currentTrack == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('No song selected.'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                playerState.currentTrack!.artwork != null
                    ? Image.memory(
                        playerState.currentTrack!.artwork as Uint8List,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.music_note, size: 300),
                const SizedBox(height: 20),
                Text(
                  playerState.currentTrack!.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  playerState.currentTrack!.artist,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_position.toString().split('.').first),
                      Text(_duration.toString().split('.').first),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 48,
                      onPressed: () {
                        // Implement previous song logic
                      },
                    ),
                    IconButton(
                      icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 64,
                      onPressed: () {
                        if (playerState.isPlaying) {
                          _audioPlayer.pause();
                        } else {
                          _audioPlayer.resume();
                        }
                        playerState.setIsPlaying(!playerState.isPlaying);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 48,
                      onPressed: () {
                        // Implement next song logic
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
