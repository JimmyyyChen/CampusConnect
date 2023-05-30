import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postTextController = TextEditingController();
  String? _tag;
  File? _image;
  VideoPlayerController? _videoPlayerController;
  File? _videoFile;
  Position? _currentPosition;

  Future<void> _getCurrentLocation() async {
    bool isLocationServiceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // 位置服务未启用，显示错误提示
      // ...
      return;
    }

    // 请求位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 位置权限被拒绝，请求权限
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 位置权限被拒绝，显示错误提示
        // ...
        return;
      }
    }

    // 获取当前位置
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _getVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布新的帖子'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _postTextController,
                decoration: const InputDecoration(
                  hintText: '请输入您的帖子内容',
                ),
                maxLines: 10,
                onChanged: (_) {
                  // 在用户输入或编辑帖子内容时更新 Markdown 格式的文本
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _tag,
                  hint: const Text('请选择标签'),
                  items: const [
                    DropdownMenuItem(
                      value: '校园资讯',
                      child: Text('校园资讯'),
                    ),
                    DropdownMenuItem(
                      value: '二手交易',
                      child: Text('二手交易'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tag = value;
                    });
                  },
                ),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('添加位置'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_image != null)
              Image.file(
                _image!,
                height: 200.0,
              ),
            if (_videoFile != null && _videoPlayerController != null)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _getImage,
                  icon: const Icon(Icons.image),
                  label: const Text('添加图片'),
                ),
                ElevatedButton.icon(
                  onPressed: _getVideo,
                  icon: const Icon(Icons.video_camera_back),
                  label: const Text('添加视频'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 在这里添加发布帖子的逻辑
                    final String postText = _postTextController.text;
                    print('您输入的帖子内容是： $postText');
                    if (_image != null) {
                      // 处理上传图片的逻辑
                      print('您上传的图片路径是： ${_image!.path}');
                    }
                    if (_videoFile != null) {
                      // 处理上传视频的逻辑
                      print('您上传的视频路径是： ${_videoFile!.path}');
                    }
                    if (_currentPosition != null) {
                      // 处理位置信息的逻辑
                      final double latitude = _currentPosition!.latitude;
                      final double longitude = _currentPosition!.longitude;
                      print('您的位置信息是： $latitude, $longitude');
                      log('您的位置信息是： $latitude, $longitude');
                    }
                    if (_tag != null) {
                      // 处理帖子标签的逻辑
                      print('您选择的标签是： $_tag');
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('发布'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: _postTextController.text,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
