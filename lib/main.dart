import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:local_audio_scan/local_audio_scan.dart';
import 'package:provider/provider.dart';
import 'player_state.dart';
import 'now_playing_screen.dart';
import 'mini_player.dart';
import 'themes.dart';
import 'settings_screen.dart';
import 'theme_provider.dart';
import 'package:audio_background/audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioBackgroundService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlayerStateModel()),
        ChangeniofierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Music Player',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MusicPlayerHome(),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});

  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  final _localAudioScanner = LocalAudioScanner();
  List<AudioTrack> _audioTracks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scanAudioFiles(); // Automatically scan for songs on startup
  }

  Future<void> _scanAudioFiles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final hasPermission = await _localAudioScanner.requestPermission();
      if (hasPermission) {
        final tracks = await _localAudioScanner.scanTracks(filterJunkAudio: true); // Filter junk audio by default
        if (mounted) {
          setState(() {
            _audioTracks = tracks;
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _play(AudioTrack track) async {
    final playerState = Provider.of<PlayerStateModel>(context, listen: false);
    await AudioBackgroundService.play(MediaItem(
      title: track.title,
      artist: track.artist,
      url: track.filePath,
    ));
    playerState.setCurrentTrack(track);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<PlayerStateModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: Provider.of<ThemeProvider>(context),
                    child: const SettingsScreen(),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _audioTracks.length,
                    itemBuilder: (context, index) {
                      final track = _audioTracks[index];
                      final isPlaying = playerState.currentTrack?.filePath == track.filePath && playerState.isPlaying;
                      return ListTile(
                        leading: track.artwork != null
                            ? Image.memory(track.artwork as Uint8List, width: 50, height: 50, fit: BoxFit.cover,)
                            : const Icon(Icons.music_note, size: 50,),
                        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        onTap: () {
                          _play(track);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (isPlaying) {
                              AudioBackgroundService.pause();
                            } else {
                              _play(track);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (playerState.currentTrack != null)
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
                        );
                      },
                      child: const MiniPlayer()),
              ],
            ),
    );
  }
}
