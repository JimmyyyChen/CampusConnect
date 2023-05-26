import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forum/app_state.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();

    commentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Detail"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Consumer<ApplicationState>(
                  builder: (context, appState, _) => PostWidget(
                      postUid: widget.postUid,
                      authorUID: appState.posts[widget.postUid]!.authorUID,
                      postTime: appState.posts[widget.postUid]!.postTime,
                      isFollowed: appState.follows
                          .contains(appState.posts[widget.postUid]!.authorUID),
                      content: appState.posts[widget.postUid]!.content,
                      type: appState.posts[widget.postUid]!.type,
                      isFavorite:
                          appState.favoritePostsId.contains(widget.postUid),
                      isLike: appState.likedPostsId.contains(widget.postUid),
                      comment: () {
                        commentFocusNode.requestFocus();
                      }),
                ),
                // TODO: comments view
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
                      focusNode: commentFocusNode,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
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
    required this.comment,
  });

  final Comment comment;

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
            Column(
              children: [
                Text(comment.name),
                Text(comment.commentTime.toString()),
                Text(comment.content),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
