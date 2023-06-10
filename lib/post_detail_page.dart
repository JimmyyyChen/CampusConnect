import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/app_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'classes/post.dart';
import 'post_widget.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postUid});

  final String postUid;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late FocusNode commentFocusNode;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    commentFocusNode = FocusNode();
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentFocusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Consumer<ApplicationState>(
                  builder: (context, appState, _) => PostWidget(
                      isDetailed: true,
                      showVideoThumbnail: false, // can play video
                      post: appState.posts[widget.postUid]!,
                      isFavorite:
                          appState.favoritePostsId.contains(widget.postUid),
                      isFollowed: appState.follows
                          .contains(appState.posts[widget.postUid]!.authoruid),
                      isLike: appState.likedPostsId.contains(widget.postUid),
                      commentAction: () {
                        commentFocusNode.requestFocus();
                      }),
                ),
                Consumer<ApplicationState>(
                  builder: (context, appState, _) =>
                      StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postUid)
                        .collection('comments')
                        .orderBy('commentTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot comment = snapshot.data!.docs[index];
                          // get user name by comment['authorUid'],
                          return CommentWidget(
                            name: comment['authorUid'],
                            content: comment['content'],
                            commentTime: comment['commentTime'],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: commentController,
                      focusNode: commentFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                      ),
                      // onSubmitted: (String value) {
                      //   FirebaseFirestore.instance
                      //       .collection('posts')
                      //       .doc(widget.postUid)
                      //       .collection('comments')
                      //       .add({
                      //     'authorUid': FirebaseAuth.instance.currentUser!.uid,
                      //     'content': value,
                      //     'commentTime': Timestamp.now(),
                      //   });
                      //   // add commentCount
                      //   FirebaseFirestore.instance
                      //       .collection('posts')
                      //       .doc(widget.postUid)
                      //       .update({
                      //     'commentCount': FieldValue.increment(1),
                      //   });
                      //   commentController.clear();
                      // }
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // get current user name
                    String userName = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get()
                        .then((DocumentSnapshot documentSnapshot) {
                      if (documentSnapshot.exists) {
                        return documentSnapshot['name'];
                      } else {
                        return "unknown";
                      }
                    });
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postUid)
                        .collection('comments')
                        .add({
                      'authorUid': userName,
                      // 'authorUid': FirebaseAuth.instance.currentUser!.uid,
                      'content': commentController.text,
                      'commentTime': Timestamp.now(),
                    });
                    //send notification
                    try {
                      // BFTlg14_25pHXUUSVSQWq4GIQXskgU-bMrAKIWl_FoPMAda7yMvrRWuMmXYGmKsjAUB2wiLrH93znSZqdqo6ZOU
                      var serverKey =
                          'AAAAwp4ZTao:APA91bFtJ2NPY2GUMWfWX81rp-JuwmTaFmrI4_vHAQX0pmGNyNhIOhDReedW4dqmoLQtf07F5HspHf7q9HH7xsq8-DiIKD0SEH6NSWf5amWf2jrLy2XPXtDBUMW1wwXCvut6ybcyEbs-';
                      var url =
                          Uri.parse('https://fcm.googleapis.com/fcm/send');

                      var headers = {
                        'Content-Type': 'application/json',
                        'Authorization': 'key=$serverKey',
                      };

                      Post post =
                          Provider.of<ApplicationState>(context, listen: false)
                              .posts[widget.postUid]!;

                      var querySnapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .where('uid', isEqualTo: post.authoruid)
                          .get();

                      var fcmToken = "0";
                      // "eAdnWZ94Tr-ksrYsG7eM8i:APA91bEKvcM-J-5d5z6JRPdDwNu5VJQIDq8bDuC2X4crvtay7y0Jg0FestUUpoNr0lHQLysgh2f1sitx9droA3dT6L0U2JhNlCFdtrgSZyBA24dSaRAlrfunMG2j6-wV3TJK8MWo-txe";

                      if (querySnapshot.docs.isNotEmpty) {
                        var userData = querySnapshot.docs[0].data();
                        fcmToken = userData['fcmToken'];
                      }
                      print("fcmToken is " + fcmToken);

                      var message = {
                        'notification': {
                          'title': "您收到了一条评论",
                          'body': commentController.text,
                        },
                        'to': fcmToken,
                      };

                      var response = await http.post(url,
                          headers: headers, body: jsonEncode(message));

                      if (response.statusCode == 200) {
                        print('Notification sent successfully.');
                      } else {
                        print('Error1 sending notification: ${response.body}');
                      }
                    } catch (e) {
                      print('Error2 sending notification: $e');
                    }
                    // add commentCount
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postUid)
                        .update({
                      'commentCount': FieldValue.increment(1),
                    });
                    commentController.clear();
                    commentFocusNode.unfocus();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.name,
    required this.content,
    required this.commentTime,
  });

  final String name;
  final String content;
  final Timestamp commentTime;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // TODO: add user image
            // CircleAvatar(
            //   // backgroundImage: NetworkImage(comment.userImage),
            //   // random color
            //   backgroundColor: Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
            // ),
            // const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    commentTime.toDate().toString().substring(
                        0, commentTime.toDate().toString().length - 7),
                    style: const TextStyle(fontSize: 10.0)),
                const SizedBox(height: 8.0),
                Text(content),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
