import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  File? _image;
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
        _image = File(image.path);
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
        _image = File(image.path);
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
        _image = null;
        _videoFile = File(image.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {
              _image = null;
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
        _image = null;
        _videoFile = File(image.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {
              _image = null;
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
                        hintText: '请输入您的帖子内容',
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
                        if (_postTextController.text.isNotEmpty)
                          MarkdownBody(
                            data: _postTextController.text,
                            styleSheet: MarkdownStyleSheet(
                              // every thin has same color
                              p: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize,
                              ),
                              h1: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 2,
                              ),
                              h2: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 1.5,
                              ),
                              h3: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 1.17,
                              ),
                              h4: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 1.12,
                              ),
                              h5: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 1.07,
                              ),
                              h6: TextStyle(
                                color: _fontColor,
                                fontSize: _fontSize * 1.05,
                              ),
                              listBullet: TextStyle(
                                  color: _fontColor, fontSize: _fontSize),
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
                        // TODO
                        _image == null
                            ? Container()
                            : Image.file(_image!,
                                width: MediaQuery.of(context).size.width / 2,
                                height: MediaQuery.of(context).size.width / 2),
                        _videoFile == null
                            ? Container()
                            :
                            // video player and progress indicator
                            Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_videoPlayerController!
                                            .value.isPlaying) {
                                          _videoPlayerController!.pause();
                                        } else {
                                          _videoPlayerController!.play();
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: AspectRatio(
                                        aspectRatio: _videoPlayerController!
                                            .value.aspectRatio,
                                        child: VideoPlayer(
                                            _videoPlayerController!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                  // log('您的位置信息是： $latitude, $longitude');
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
      ),
    );
  }
}
