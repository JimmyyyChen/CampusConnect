import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.postUid,
    required this.authorUID,
    required this.postTime,
    required this.isFollowed,
    required this.content,
    required this.type,
    required this.isFavorite,
    required this.isLike,
    required this.comment,
  });

  final String postUid;
  final String authorUID;
  final Timestamp postTime;
  final bool isFollowed;
  final String content;
  final String type;
  final bool isFavorite;
  final bool isLike;
  final void Function() comment;

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
                    // Text(widget.post.authorUID),
                    // add different style for author
                    Text(
                      // widget.post.authorUID,
                      widget.authorUID,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                        widget.postTime.toDate().toString().substring(
                            0, widget.postTime.toDate().toString().length - 7),
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
                        'follows': FieldValue.arrayRemove([widget.authorUID])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows': FieldValue.arrayUnion([widget.authorUID])
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.content,
                  style: const TextStyle(
                    fontSize: 20,
                  )),
            ),
            // tag
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(widget.type,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    )),
              ),
            ),
            // TODO: read images from firebase storage
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
              shrinkWrap: true,
              children: List.generate(1, (index) {
                // return Image.network(widget.post.images[index]);
                // random color
                return Container(
                  color: Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
                );
              }),
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
                            FieldValue.arrayRemove([widget.postUid])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'likedPostsId':
                            FieldValue.arrayUnion([widget.postUid])
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(widget.isLike ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                      const Text('Like'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: widget.comment,
                  child: const Row(
                    children: [
                      Icon(Icons.comment),
                      Text('Comment'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
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
                            FieldValue.arrayRemove([widget.postUid])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'favoritePostsId':
                            FieldValue.arrayUnion([widget.postUid])
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
