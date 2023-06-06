import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class PostContentViewer extends StatefulWidget {
  const PostContentViewer({
    super.key,
    required this.markdownText,
    required this.fontSize,
    required this.fontColor,
    required this.showVideoThumbnail,
    this.imageUrl,
    this.videoUrl,
    this.imageFile, // TODO
    this.videoFile,
  });

  final String markdownText;
  final double fontSize;
  final Color fontColor;
  final File? imageFile;
  final String? imageUrl;
  final String? videoUrl;
  final File? videoFile;
  final bool showVideoThumbnail;

  @override
  State<PostContentViewer> createState() => _PostContentViewerState();
}

class _PostContentViewerState extends State<PostContentViewer> {
  VideoPlayerController? _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;
  // String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      // _loadThumbnail();
    }
  }

  // void _loadThumbnail() async {
  //   _thumbnailPath = await VideoThumbnail.thumbnailFile(
  //     video: widget.videoUrl!,
  //     // thumbnailPath: (await getTemporaryDirectory()).path,
  //     imageFormat: ImageFormat.WEBP,
  //     maxHeight:
  //         64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //     quality: 75,
  //   );
  //   setState(() {}); // 更新状态以触发UI重建
  // }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl != null || widget.imageFile != null) {
      _videoPlayerController = null;
    }
    if (widget.videoUrl != null && _videoPlayerController == null) {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
    }
    if (widget.videoFile != null && _videoPlayerController == null) {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!);
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.markdownText.isNotEmpty)
            MarkdownBody(
              data: widget.markdownText,
              styleSheet: MarkdownStyleSheet(
                // every thin has same color
                p: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize,
                ),
                h1: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 2,
                ),
                h2: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 1.5,
                ),
                h3: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 1.17,
                ),
                h4: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 1.12,
                ),
                h5: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 1.07,
                ),
                h6: TextStyle(
                  color: widget.fontColor,
                  fontSize: widget.fontSize * 1.05,
                ),
                listBullet: TextStyle(
                    color: widget.fontColor, fontSize: widget.fontSize),
              ),
            )
          else
            const Center(
              child: Text(
                'Markdown文本为空',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 8),
          // image viewer for network image
          widget.imageUrl == null
              ? Container()
              : Center(
                  child: Image.network(widget.imageUrl!,
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2),
                ),

          // image viewer for local image when creating post
          widget.imageFile == null
              ? Container()
              : Center(
                  child: Image.file(widget.imageFile!,
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2),
                ),
          // video viewer for local video when creating post

          if (widget.videoUrl != null || widget.videoFile != null)
            if (widget.showVideoThumbnail)
              const Center(
                child: Icon(
                  Icons.slow_motion_video_sharp,
                  size: 70,
                ),
              )
            // TODO: it works, but it's ugly
            // if (widget.showVideoThumbnail && _thumbnailPath != null)
            // show thumbnail of video
            // Image.file(
            //   File(_thumbnailPath!),
            // )
            else
              Center(
                child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the VideoPlayerController has finished initialization, use
                        // the data it provides to limit the aspect ratio of the video.
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_videoPlayerController!.value.isPlaying) {
                                _videoPlayerController!.pause();
                              } else {
                                _videoPlayerController!.play();
                              }
                            });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController!.value.aspectRatio,
                              // Use the VideoPlayer widget to display the video.
                              // child: VideoPlayer(_videoPlayerController!),

                              child: Stack(
                                children: [
                                  VideoPlayer(_videoPlayerController!),
                                  if (!_videoPlayerController!.value.isPlaying)
                                    const Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 100,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
        ],
      ),
    );
  }
}
