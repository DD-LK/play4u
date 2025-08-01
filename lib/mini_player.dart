import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: const Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.music_note, color: Colors.white),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Song Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Artist Name', style: TextStyle(color: Colors.white70)),
            ],
          ),
          Spacer(),
          IconButton(icon: Icon(Icons.play_arrow), color: Colors.white, onPressed: null),
          IconButton(icon: Icon(Icons.skip_next), color: Colors.white, onPressed: null),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
