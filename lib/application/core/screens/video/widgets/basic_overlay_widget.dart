import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class BasicOverlayWidget extends StatelessWidget {
  const BasicOverlayWidget({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);
  final VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => videoPlayerController.value.isPlaying
            ? videoPlayerController.pause()
            : videoPlayerController.play(),
        child: Stack(
          children: [
            buildPlay(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildIndicator(),
            ),
          ],
        ),
      );

  Widget buildIndicator() => VideoProgressIndicator(
        videoPlayerController,
        allowScrubbing: true,
      );

  Widget buildPlay() => videoPlayerController.value.isPlaying
      ? Container()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: const Icon(LineAwesomeIcons.play_circle),
        );
}
