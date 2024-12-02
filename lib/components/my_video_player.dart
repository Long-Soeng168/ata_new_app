import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({
    super.key,
    required this.url,
    required this.dataSourceType,
    this.aspectRatio = 16 / 9, // Allow customizable aspect ratio
  });

  final String url;
  final DataSourceType dataSourceType;
  final double aspectRatio;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      switch (widget.dataSourceType) {
        case DataSourceType.asset:
          _videoPlayerController = VideoPlayerController.asset(widget.url);
          break;
        case DataSourceType.network:
          _videoPlayerController =
              VideoPlayerController.networkUrl(Uri.parse(widget.url));
          break;
        case DataSourceType.file:
          _videoPlayerController = VideoPlayerController.file(File(widget.url));
          break;
        case DataSourceType.contentUri:
          _videoPlayerController =
              VideoPlayerController.contentUri(Uri.parse(widget.url));
          break;
      }

      await _videoPlayerController.initialize();
      setState(() {
        _isLoading = false;
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: widget.aspectRatio,
          autoPlay: true,
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.url);
    if (_isLoading) {
      return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
    }

    if (_hasError) {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Failed to load video'),
        // ElevatedButton(
        //   onPressed: _initializeVideoPlayer,
        //   child: const Text('Retry'),
        // ),
      ],
    ),
  );
}


    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
