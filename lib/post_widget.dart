import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'classes/post.dart';
import 'post_content_viewer.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
    required this.commentAction,
    required this.isFollowed,
    required this.isLike,
    required this.isFavorite,
  });

  final Post post;
  final void Function() commentAction;
  final bool isFollowed;
  final bool isLike;
  final bool isFavorite;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  // backgroundImage: NetworkImage(widget.post.userImage),
                  // random color
                  backgroundColor:
                      Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // cut author name if too long
                    Text(
                      widget.post.authoruid.length > 10
                          ? widget.post.authoruid.substring(0, 10) + '...'
                          : widget.post.authoruid,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                        widget.post.postTime.toDate().toString().substring(
                            0,
                            widget.post.postTime.toDate().toString().length -
                                7),
                        style: const TextStyle(
                          color: Colors.grey,
                        )),
                  ],
                ),
                // button for following
                const Expanded(child: SizedBox()),
                TextButton(
                  onPressed: () async {
                    if (widget.isFollowed) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows':
                            FieldValue.arrayRemove([widget.post.authoruid])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows':
                            FieldValue.arrayUnion([widget.post.authoruid])
                      });
                    }
                  }, // TODO
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.isFollowed ? Icons.check : Icons.add),
                      Text(widget.isFollowed ? 'Following' : 'Follow'),
                    ],
                  ),
                ),
              ],
            ),
            PostContentViewer(
              fontColor: widget.post.fontColor,
              fontSize: widget.post.fontSize,
              markdownText: widget.post.markdownText,
            ),
            Row(
              children: [
                // tag
                if (widget.post.tag != null)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(widget.post.tag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),

                // location
                if (widget.post.location != null)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                          '位置(${widget.post.location!.latitude.toStringAsFixed(2)}, ${widget.post.location!.longitude.toStringAsFixed(2)})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    if (widget.isLike) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'likedPostsId':
                            FieldValue.arrayRemove([widget.post.postuid])
                      });
                      // decrease likeCount to post
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.post.postuid)
                          .update({
                        'likeCount': FieldValue.increment(-1),
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'likedPostsId':
                            FieldValue.arrayUnion([widget.post.postuid])
                      });
                      // add likeCount to post
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.post.postuid)
                          .update({
                        'likeCount': FieldValue.increment(1),
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(widget.isLike
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined),
                      Text('Like ${widget.post.likeCount}'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.commentAction,
                  child: const Row(
                    children: [
                      Icon(Icons.comment),
                      Text('Comment'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {}, //TODO : 分享界面实现
                  child: const Row(
                    children: [
                      Icon(Icons.share),
                      Text('Share'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (widget.isFavorite) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'favoritePostsId':
                            FieldValue.arrayRemove([widget.post.postuid])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'favoritePostsId':
                            FieldValue.arrayUnion([widget.post.postuid])
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(widget.isFavorite ? Icons.star : Icons.star_border),
                      const Text('Favorite'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
