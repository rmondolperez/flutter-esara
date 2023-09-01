import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:esara/application/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AudioFileWidget extends StatefulWidget {
  const AudioFileWidget({
    super.key,
    required this.fileSystemEntity,
  });
  final FileSystemEntity fileSystemEntity;

  @override
  State<AudioFileWidget> createState() => _AudioFileWidgetState();
}

class _AudioFileWidgetState extends State<AudioFileWidget> {
  final audioPlayer = AudioPlayer();
  Duration audioDuration = Duration.zero;
  Duration audioPosition = Duration.zero;
  bool isRecorderReady = false;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        audioDuration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newAudioPosition) {
      setState(() {
        audioPosition = newAudioPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((complete) {
      setState(() {
        audioPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = (MediaQuery.of(context).size.height / 3);
    return Scaffold(
      body: SizedBox(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: height),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.play(
                        UrlSource(widget.fileSystemEntity.path),
                      );
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(2.0)),
                      backgroundColor: MaterialStateProperty.all(tPrimaryColor),
                      overlayColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.blue;
                        }
                      })),
                  child: Icon(
                    isPlaying
                        ? LineAwesomeIcons.pause_circle
                        : LineAwesomeIcons.play_circle,
                    size: 120.0,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayColor: tPrimaryColor,
                    thumbColor: tPrimaryColor,
                    activeTrackColor: tPrimaryColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: audioDuration.inSeconds.toDouble(),
                    value: audioPosition.inSeconds.toDouble(),
                    onChanged: (value) async {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(audioPosition)),
                      Text(_formatTime(audioDuration - audioPosition)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
