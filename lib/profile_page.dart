import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/user.dart';
import 'package:forum/pages/chat_screen.dart';
import 'package:forum/post_detail_page.dart';
import 'package:forum/post_widget.dart';
import 'package:provider/provider.dart';

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
  List<String> _follows = [];
  List<String> _blocks = [];

  void blockUser() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'blocks': FieldValue.arrayUnion([widget.uid]),
      'follows': FieldValue.arrayRemove([widget.uid])
    });
    setState(() {
      blocked = true;
      followed = false;
    });
  }

  void unblockUser() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'blocks': FieldValue.arrayRemove([widget.uid])
    });
    setState(() {
      blocked = false;
    });
  }

  void followUser() {
    if (!blocked) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'follows': FieldValue.arrayUnion([widget.uid])
      });
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
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'follows': FieldValue.arrayRemove([widget.uid])
    });
    setState(() {
      followed = false;
    });
  }

  void sendMessage() {
    if (followed) {
      // 处理发送私信逻辑
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat_Screen(uid: widget.uid),
          ));
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
    DocumentSnapshot documentSnapshot2 = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    // 处理数据
    Map<String, dynamic> userData2 =
        documentSnapshot2.data() as Map<String, dynamic>;
    if (userData2['follows'] != null) {
      List<dynamic> followsDynamic2 = userData2['follows'];
      List<dynamic> followsDynamic3 = userData2['blocks'];
      _follows = List<String>.from(followsDynamic2);
      _blocks = List<String>.from(followsDynamic3);
    }

    // print("follows: $_follows");
    // 数据获取完成后触发UI更新
    setState(() {
      _userData = _userData;
      followed = _follows.contains(widget.uid);
      blocked = _blocks.contains(widget.uid);
      // print("uid: ${widget.uid}");
      // print("followed: $followed");
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
                  if ((appState.posts[postuid]!.authoruid != widget.uid) ||
                      blocked) {
                    return Container();
                  }
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
    );
  }
}
