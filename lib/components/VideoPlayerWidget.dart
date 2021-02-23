import 'dart:io';

import 'package:eop_mobile/utils/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  VideoPlayerWidget({this.file});
  final File file;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.setVolume(1.0);
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _controller.value.initialized
          ? SizedBox(
              height: 300,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : Container(),
      CircleAvatar(
        radius: 20.0,
        child: IconButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          icon: Icon(
            (_controller.value.isPlaying) ? Icons.pause : Icons.play_arrow,
            color: kPrimaryThemeColor,
          ),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
