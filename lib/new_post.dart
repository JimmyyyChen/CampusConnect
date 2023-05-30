import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:forum/post_content_viewer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _postTextController = TextEditingController();
  String? _tag;
  File? _imageFile;
  VideoPlayerController? _videoPlayerController;
  File? _videoFile;
  Position? _currentPosition;
  bool _isEditingMarkdown = true;
  // font color
  Color _fontColor = Colors.black;
  double _fontSize = 16;

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
    // TODO: BUG
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
        _imageFile = File(image.path);
        _videoFile = null;
      });
    }

    // set isEditingMarkdown to false
    setState(() {
      _isEditingMarkdown = false;
    });
  }

  Future<void> _takeImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _videoFile = null;
      });
    }

    // set isEditingMarkdown to false
    setState(() {
      _isEditingMarkdown = false;
    });
  }

  Future<void> _getVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickVideo(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = null;
        _videoFile = File(image.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {
              _imageFile = null;
            });
          });
      });
    }

    // set isEditingMarkdown to false
    setState(() {
      _isEditingMarkdown = false;
    });
  }

  Future<void> _takeVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickVideo(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageFile = null;
        _videoFile = File(image.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {
              _imageFile = null;
            });
          });
      });
    }

    // set isEditingMarkdown to false
    setState(() {
      _isEditingMarkdown = false;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '预览',
                  style: TextStyle(
                    color: _isEditingMarkdown ? Colors.grey : null,
                  ),
                ),
                Switch(
                  // set color so that there is no difference between active and inactive
                  activeColor: Colors.grey.shade300,
                  inactiveTrackColor: Colors.grey.shade300,
                  inactiveThumbColor: Colors.grey.shade300,
                  value: _isEditingMarkdown,
                  onChanged: (value) {
                    setState(() {
                      _isEditingMarkdown = value;
                    });
                  },
                ),
                Text(
                  '编辑Markdown文本',
                  style: TextStyle(
                    color: _isEditingMarkdown ? null : Colors.grey,
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isEditingMarkdown
                  ? TextFormField(
                      controller: _postTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入Markdown文本',
                      ),
                      style: TextStyle(
                        color: _fontColor,
                        fontSize: _fontSize,
                      ),
                      maxLines: 30,
                      autofocus: true,
                      // whenever not focused
                    )
                  : ListView(
                      children: [
                        PostContentViewer(
                          markdownText: _postTextController.text,
                          fontSize: _fontSize,
                          fontColor: _fontColor,
                          imageFile: _imageFile,
                          videoFile: _videoFile,
                          videoPlayerController: _videoPlayerController,
                        )
                      ],
                    ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // space between children
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
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.location_on),
                    label: Text(
                      _currentPosition == null
                          ? '添加位置'
                          : '已添加经纬度： ${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _currentPosition == null
                            ? null
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _getImage,
                    icon: const Icon(Icons.image),
                    label: const Text('添加图片'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _getVideo,
                    icon: const Icon(Icons.video_camera_back),
                    label: const Text('添加视频'),
                  ),
                  TextButton.icon(
                    onPressed: _takeImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('照相'),
                  ),
                  TextButton.icon(
                    onPressed: _takeVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('录影'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // a pop up to choose color from color picker
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const Text('选择字体大小',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  StatefulBuilder(builder: (context, state) {
                                    return Slider(
                                      value: _fontSize,
                                      min: 10,
                                      max: 30,
                                      divisions: 4,
                                      label: _fontSize.round().toString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _fontSize = value;
                                        });
                                        state(() {
                                          _fontSize = value;
                                        });
                                      },
                                    );
                                  }),
                                  const Text('选择字体颜色',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  BlockPicker(
                                    pickerColor: _fontColor,
                                    onColorChanged: (color) {
                                      setState(() {
                                        _fontColor = color;
                                      });
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.text_format),
                    label: const Text('文字样式'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('posts').add({
                  'authoruid': FirebaseAuth.instance.currentUser!.uid,
                  'markdownText': _postTextController.text,
                  'postTime': Timestamp.now(),
                  'tag': _tag,
                  'location': _currentPosition == null
                      ? null
                      : GeoPoint(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                  'fontColor': _fontColor.value,
                  'fontSize': _fontSize,
                  'likeCount': 0,
                  // TODO
                  // 'image' : _image == null ? null : _image!.path,
                  // 'video' : _videoFile == null ? null : _videoFile!.path,
                  // comments collection would be added in post_detail_page.dart if there is a comment
                });

                Navigator.pop(context);
              },
              child: const Text('发布'),
            ),
          ],
        ),
      ),
    );
  }
}
