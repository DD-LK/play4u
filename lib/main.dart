import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:local_audio_scan/local_audio_scan.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instance of the local audio scanner
  final _localAudioScanner = LocalAudioScanner();

  // Instance of the audio player
  final _audioPlayer = AudioPlayer();

  // List to hold the scanned audio tracks
  List<AudioTrack> _audioTracks = [];

  // Flag to indicate if the app is currently scanning for audio files
  bool _isLoading = false;

  // Status message to display to the user
  String _status = 'Tap the button to scan for audio files.';

  // Path of the currently playing audio track
  String? _currentlyPlaying;

  // Current state of the audio player
  PlayerState _playerState = PlayerState.stopped;

  // Flag to filter out junk audio files
  bool _filterJunkAudio = true;

  @override
  void initState() {
    super.initState();
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose the audio player when the widget is disposed
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Scans for local audio files.
  Future<void> _scanAudioFiles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _status = 'Scanning...';
    });

    try {
      // Request permission to access local audio files
      final hasPermission = await _localAudioScanner.requestPermission();
      if (hasPermission) {
        // Scan for audio tracks
        final tracks = await _localAudioScanner.scanTracks(filterJunkAudio: _filterJunkAudio);
        if (mounted) {
          setState(() {
            _audioTracks = tracks;
            _status = 'Found ${_audioTracks.length} tracks.';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _status = 'Permission denied.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Plays the audio track at the given [path].
  Future<void> _play(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
    if (mounted) {
      setState(() {
        _currentlyPlaying = path;
      });
    }
  }

  /// Pauses the currently playing audio track.
  Future<void> _pause() async {
    await _audioPlayer.pause();
    if (mounted) {
      setState(() {
        _currentlyPlaying = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Music Player'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(_status),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Filter Junk Audio'),
                      Switch(
                        value: _filterJunkAudio,
                        onChanged: (value) {
                          setState(() {
                            _filterJunkAudio = value;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _scanAudioFiles,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Scan Local Audio'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _audioTracks.length,
                itemBuilder: (context, index) {
                  final track = _audioTracks[index];
                  final isPlaying = _currentlyPlaying == track.filePath && _playerState == PlayerState.playing;
                  return ListTile(
                    leading: track.artwork != null
                        ? Image.memory(track.artwork as Uint8List, width: 50, height: 50, fit: BoxFit.cover,)
                        : const Icon(Icons.music_note, size: 50,),
                    title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    trailing: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        if (isPlaying) {
                          _pause();
                        } else {
                          _play(track.filePath);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
