import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/app_state.dart';
import 'package:provider/provider.dart';

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
                        onSubmitted: (String value) {
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postUid)
                              .collection('comments')
                              .add({
                            'authorUid': FirebaseAuth.instance.currentUser!.uid,
                            'content': value,
                            'commentTime': Timestamp.now(),
                          });
                          // add commentCount
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postUid)
                              .update({
                            'commentCount': FieldValue.increment(1),
                          });
                          commentController.clear();
                        }),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.postUid)
                        .collection('comments')
                        .add({
                      'authorUid': FirebaseAuth.instance.currentUser!.uid,
                      'content': commentController.text,
                      'commentTime': Timestamp.now(),
                    });
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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              // backgroundImage: NetworkImage(comment.userImage),
              // random color
              backgroundColor: Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
            ),
            const SizedBox(width: 8.0),
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
