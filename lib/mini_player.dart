import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_state.dart';
import 'package:audioplayers/audioplayers.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerState = Provider.of<PlayerStateModel>(context);
    final audioPlayer = AudioPlayer();

    return Container(
      height: 60,
      color: Colors.blueGrey[800],
      child: Consumer<PlayerStateModel>(
        builder: (context, playerState, child) {
          if (playerState.currentTrack == null) {
            return const SizedBox.shrink();
          }
          return Row(
            children: [
              const SizedBox(width: 10),
              playerState.currentTrack!.artwork != null
                  ? Image.memory(playerState.currentTrack!.artwork!, width: 40, height: 40, fit: BoxFit.cover)
                  : const Icon(Icons.music_note, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerState.currentTrack!.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      playerState.currentTrack!.artist,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(playerState.isPlaying ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                onPressed: () {
                  if (playerState.isPlaying) {
                    audioPlayer.pause();
                  } else {
                    audioPlayer.play(DeviceFileSource(playerState.currentTrack!.filePath));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                color: Colors.white,
                onPressed: () {
                  // Implement next song logic
                },
              ),
              const SizedBox(width: 10),
            ],
          );
        },
      ),
    );
  }
}
