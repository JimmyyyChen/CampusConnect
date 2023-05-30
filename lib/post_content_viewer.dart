import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:video_player/video_player.dart';

class PostContentViewer extends StatefulWidget {
  const PostContentViewer({
    super.key,
    required this.markdownText,
    required this.fontSize,
    required this.fontColor,
    this.imageFile, // TODO
    this.videoFile,
    this.videoPlayerController,
  });

  final String markdownText;
  final double fontSize;
  final Color fontColor;
  final File? imageFile;
  final File? videoFile;
  final VideoPlayerController? videoPlayerController;

  @override
  State<PostContentViewer> createState() => _PostContentViewerState();
}

class _PostContentViewerState extends State<PostContentViewer> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
              listBullet:
                  TextStyle(color: widget.fontColor, fontSize: widget.fontSize),
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
        // image viewer
        widget.imageFile == null
            ? Container()
            : Image.file(widget.imageFile!,
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 2),
        // video viewer
        widget.videoFile == null
            ? Container()
            : Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (widget.videoPlayerController!.value.isPlaying) {
                          widget.videoPlayerController!.pause();
                        } else {
                          widget.videoPlayerController!.play();
                        }
                      });
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: AspectRatio(
                        aspectRatio:
                            widget.videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(widget.videoPlayerController!),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
