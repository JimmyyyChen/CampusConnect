import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'classes/post.dart';
import 'post_detail_page.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
    required this.isStar,
    required this.isLike,
    required this.isUserFollowed,
  });

  final Post post;
  final bool isStar;
  final bool isLike;
  final bool isUserFollowed;

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
                      widget.post.authorUID,
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
                    if (widget.isUserFollowed) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows':
                            FieldValue.arrayRemove([widget.post.authorUID])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows':
                            FieldValue.arrayUnion([widget.post.authorUID])
                      });
                    }
                  }, // TODO
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.isUserFollowed ? Icons.check : Icons.add),
                      Text(widget.isUserFollowed ? 'Following' : 'Follow'),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.post.content,
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
                child: Text(widget.post.type,
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
              children: List.generate(widget.post.pic.length, (index) {
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
                  // TODO:
                  // onPressed: () => setState(() {
                  //   widget.isLike = !widget.isLike;
                  //   // TODO: logic
                  //   // if (PostWidget.isLike) {
                  //   //   widget.post.likes++;
                  //   // } else {
                  //   //   widget.post.likes--;
                  //   // }
                  // }),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(widget.isLike
                          ? Icons.favorite
                          : Icons.favorite_border),
                      const Text('Like'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
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
                  // TODO:
                  // onPressed: () => setState(() {
                  //   widget.isStar = !widget.isStar;
                  // }),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(widget.isStar ? Icons.star : Icons.star_border),
                      const Text('Star'),
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
