import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/user.dart';
import 'package:forum/post_detail_page.dart';
import 'package:forum/post_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'classes/post.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  bool follow = false;
  bool block = false;

  // TODO: Implement functions for button actions

  UserData _userData = UserData(
    uid: "",
    name: "",
    profileImage: "",
    introduction: "",
  );

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // 从后端获取数据
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get();

    // 处理数据
    Map<String, dynamic> userData =
        documentSnapshot.data() as Map<String, dynamic>;
    _userData = UserData(
      uid: userData['uid'],
      name: userData['name'],
      profileImage: userData['profile'],
      introduction: userData['introduction'],
    );
    // 数据获取完成后触发UI更新
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人主页'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                // onTap: () {
                // },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 10),
                      ),
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage(_userData.profileImage),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                _userData.name,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                _userData.introduction,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Handle block user functionality
                    },
                    child: Text('Block'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (block) {
                        // 已被屏蔽，显示提示
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('提示'),
                            content: Text('对方已被您屏蔽'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    block = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('确定'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 处理 block 按钮点击事件
                        // ...
                      }
                    },
                    child: Text(block ? 'Blocked' : 'Block'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (!follow) {
                        // 需要先关注，显示提示
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('提示'),
                            content: Text('需要先关注对方'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    follow = true;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('确定'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 处理 follow/unfollow 按钮点击事件
                        // ...
                      }
                    },
                    child: Text(follow ? 'Followed' : 'Follow'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      // 处理发送私信按钮点击事件
                      // ...
                    },
                    child: Text('Send Message'),
                  ),
                ],
              ),
              Consumer<ApplicationState>(
                builder: (context, appState, _) => ListView.builder(
                    itemCount: appState.posts.length,
                    itemBuilder: (context, index) {
                      String postuid = appState.posts.keys.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return PostDetailPage(
                              postUid: postuid,
                            );
                          }));
                        },
                        child: PostWidget(
                          post: appState.posts[postuid]!,
                          isFavorite:
                              appState.favoritePostsId.contains(postuid),
                          isFollowed: appState.follows
                              .contains(appState.posts[postuid]!.authoruid),
                          isLike: appState.likedPostsId.contains(postuid),
                          commentAction: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return PostDetailPage(
                                postUid: postuid,
                              );
                            }));
                          },
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
