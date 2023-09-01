import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'basic_overlay_widget.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);
  final VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) =>
      // ignore: unnecessary_null_comparison
      videoPlayerController != null && videoPlayerController.value.isInitialized
          ? Container(
              alignment: Alignment.topCenter,
              child: buildVideo(),
            )
          : const SizedBox(
              height: 200.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );

  Widget buildVideo() => Stack(
        children: [
          buildVideoPlayer(),
          Positioned.fill(
            child: BasicOverlayWidget(
              videoPlayerController: videoPlayerController,
            ),
          ),
        ],
      );

  Widget buildVideoPlayer() => AspectRatio(
        aspectRatio: videoPlayerController.value.aspectRatio,
        child: VideoPlayer(videoPlayerController),
      );
}
