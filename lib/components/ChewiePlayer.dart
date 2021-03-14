import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:eop_mobile/utils/constants.dart';

class ChewiePlayer extends StatefulWidget {
  const ChewiePlayer({this.mediaUrl, this.file});
  final File file;
  final String mediaUrl;

  @override
  State<StatefulWidget> createState() {
    return _ChewiePlayerState();
  }
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 = (widget.file == null)
        ? VideoPlayerController.network(widget.mediaUrl)
        : VideoPlayerController.file(widget.file);
    await Future.wait([_videoPlayerController1.initialize()]);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      looping: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController.videoPlayerController.value.isInitialized
        ? Chewie(
            controller: _chewieController,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading'),
            ],
          );
  }
}
