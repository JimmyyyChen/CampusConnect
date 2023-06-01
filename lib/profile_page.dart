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
  bool followed = false;
  bool blocked = false;

  void blockUser() {
    setState(() {
      blocked = true;
      followed = false;
    });
  }

  void unblockUser() {
    setState(() {
      blocked = false;
    });
  }

  void followUser() {
    if (!blocked) {
      setState(() {
        followed = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示'),
          content: Text('需要先解除屏蔽对方'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void unfollowUser() {
    setState(() {
      followed = false;
    });
  }

  void sendMessage() {
    if (followed) {
      // 处理发送私信逻辑
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('提示'),
          content: Text('需要先关注对方'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  UserData _userData = UserData(
    uid: "",
    name: "",
    profileImage: "",
    introduction: "",
  );

  @override
  void initState() {
    blocked = ApplicationState().blocks.contains(widget.uid);
    followed = ApplicationState().follows.contains(widget.uid);
    _fetchUserData();
    super.initState();
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
    setState(() {
      _userData = _userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人主页'),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => Column(
          children: [
            Padding(
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
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: blocked ? unblockUser : blockUser,
                          child: Text(blocked ? 'Unblock' : 'Block'),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: followed ? unfollowUser : followUser,
                          child: Text(followed ? 'Unfollow' : 'Follow'),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: sendMessage,
                          child: Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: appState.posts.length,
                itemBuilder: (context, index) {
                  String postuid = appState.posts.keys.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return PostDetailPage(
                          postUid: postuid,
                        );
                      }));
                    },
                    child: PostWidget(
                      post: appState.posts[postuid]!,
                      isFavorite: appState.favoritePostsId.contains(postuid),
                      isFollowed: appState.follows
                          .contains(appState.posts[postuid]!.authoruid),
                      isLike: appState.likedPostsId.contains(postuid),
                      commentAction: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return PostDetailPage(
                            postUid: postuid,
                          );
                        }));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // body: Consumer<ApplicationState>(
      //     builder: (context, appState, _) => ListView(children: [
      //           Padding(
      //             padding: EdgeInsets.all(16.0),
      //             child: Center(
      //               child: Column(
      //                 // mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   GestureDetector(
      //                     // onTap: () {
      //                     // },
      //                     child: Container(
      //                       width: 130,
      //                       height: 130,
      //                       decoration: BoxDecoration(
      //                         border: Border.all(
      //                           width: 4,
      //                           color:
      //                               Theme.of(context).scaffoldBackgroundColor,
      //                         ),
      //                         boxShadow: [
      //                           BoxShadow(
      //                             spreadRadius: 2,
      //                             blurRadius: 10,
      //                             color: Colors.black.withOpacity(0.1),
      //                             offset: const Offset(0, 10),
      //                           ),
      //                         ],
      //                         shape: BoxShape.circle,
      //                         image: DecorationImage(
      //                           fit: BoxFit.contain,
      //                           image: NetworkImage(_userData.profileImage),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   SizedBox(height: 16.0),
      //                   Text(
      //                     _userData.name,
      //                     style: TextStyle(
      //                       fontSize: 24.0,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                   ),
      //                   SizedBox(height: 8.0),
      //                   Text(
      //                     _userData.introduction,
      //                     style: TextStyle(fontSize: 16.0),
      //                   ),
      //                   SizedBox(height: 16.0),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //                       SizedBox(width: 8.0),
      //                       ElevatedButton(
      //                         onPressed: blocked ? unblockUser : blockUser,
      //                         child: Text(blocked ? 'Unblock' : 'Block'),
      //                       ),
      //                       SizedBox(height: 8.0),
      //                       ElevatedButton(
      //                         onPressed: followed ? unfollowUser : followUser,
      //                         child: Text(followed ? 'Unfollow' : 'Follow'),
      //                       ),
      //                       SizedBox(height: 8.0),
      //                       ElevatedButton(
      //                         onPressed: sendMessage,
      //                         child: Text('Send'),
      //                       ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //           Divider(),
      //           Consumer<ApplicationState>(
      //             builder: (context, appState, _) => ListView.builder(
      //                 itemCount: appState.posts.length,
      //                 itemBuilder: (context, index) {
      //                   String postuid = appState.posts.keys.elementAt(index);
      //                   return GestureDetector(
      //                     onTap: () {
      //                       Navigator.push(context,
      //                           MaterialPageRoute(builder: (_) {
      //                         return PostDetailPage(
      //                           postUid: postuid,
      //                         );
      //                       }));
      //                     },
      //                     child: PostWidget(
      //                       post: appState.posts[postuid]!,
      //                       isFavorite:
      //                           appState.favoritePostsId.contains(postuid),
      //                       isFollowed: appState.follows
      //                           .contains(appState.posts[postuid]!.authoruid),
      //                       isLike: appState.likedPostsId.contains(postuid),
      //                       commentAction: () {
      //                         Navigator.push(context,
      //                             MaterialPageRoute(builder: (_) {
      //                           return PostDetailPage(
      //                             postUid: postuid,
      //                           );
      //                         }));
      //                       },
      //                     ),
      //                   );
      //                 }),
      //           ),
      //         ]))
    );
  }
}
