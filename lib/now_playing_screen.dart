import 'package:flutter/material.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 150),
            SizedBox(height: 20),
            Text('Song Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Artist Name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.skip_previous), onPressed: null),
                IconButton(icon: Icon(Icons.play_arrow), onPressed: null),
                IconButton(icon: Icon(Icons.skip_next), onPressed: null),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
