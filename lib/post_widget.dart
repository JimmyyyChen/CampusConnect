import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/profile_page.dart';

import 'classes/post.dart';
import 'post_content_viewer.dart';
import 'package:http/http.dart' as http; //http
import 'dart:convert'; //json
import 'package:share/share.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    this.isDetailed = false,
    required this.post,
    required this.commentAction,
    required this.isFollowed,
    required this.isLike,
    required this.isFavorite,
    this.showVideoThumbnail =
        true, // if true, show video thumbnail, else show video player which can be played by tapping
    this.hasBottomBar = true,
  });

  final bool isDetailed;
  final Post post;
  final void Function() commentAction;
  final bool isFollowed;
  final bool isLike;
  final bool isFavorite;
  final bool hasBottomBar;
  final bool showVideoThumbnail;

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
                // CircleAvatar(
                //   // backgroundImage: NetworkImage(widget.post.userImage),
                //   // random color
                //   // backgroundColor:
                //   //     Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
                //   backgroundImage: NetworkImage(widget.profileImage),
                // ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(uid: widget.post.authoruid),
                        ));
                  },
                  child: CircleAvatar(
                    radius: 17.0,
                    backgroundImage:
                        //todo
                        NetworkImage(widget.post.authorProfileImage), //TODO
                    child: Container(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TODO
                    Text(
                      widget.post.authorName,
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
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'follows':
                            FieldValue.arrayRemove([widget.post.authoruid])
                      });
                    } else {
                      await FirebaseFirestore.instance
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
            const SizedBox(height: 8.0),
            PostContentViewer(
              fontColor: widget.post.fontColor,
              fontSize: widget.post.fontSize,
              markdownText: widget.post.markdownText,
              imageUrl: widget.post.imageUrl,
              videoUrl: widget.post.videoUrl,
              showVideoThumbnail: widget.showVideoThumbnail,
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
            !widget.hasBottomBar
                ? const SizedBox()
                : Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (widget.isLike) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'likedPostsId':
                                  FieldValue.arrayRemove([widget.post.postuid])
                            });
                            // decrease likeCount to post
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.post.postuid)
                                .update({
                              'likeCount': FieldValue.increment(-1),
                              // if likeCount < 1, don't decrease
                              // 'likeCount': FieldValue.increment(
                              //     widget.post.likeCount > 0 ? -1 : 0),
                            });
                          } else {
                            //发送通知
                            try {
                              // BFTlg14_25pHXUUSVSQWq4GIQXskgU-bMrAKIWl_FoPMAda7yMvrRWuMmXYGmKsjAUB2wiLrH93znSZqdqo6ZOU
                              var serverKey =
                                  'AAAAwp4ZTao:APA91bFtJ2NPY2GUMWfWX81rp-JuwmTaFmrI4_vHAQX0pmGNyNhIOhDReedW4dqmoLQtf07F5HspHf7q9HH7xsq8-DiIKD0SEH6NSWf5amWf2jrLy2XPXtDBUMW1wwXCvut6ybcyEbs-';
                              var url = Uri.parse(
                                  'https://fcm.googleapis.com/fcm/send');

                              var headers = {
                                'Content-Type': 'application/json',
                                'Authorization': 'key=$serverKey',
                              };

                              var querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .where('uid',
                                      isEqualTo: widget.post.authoruid)
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
                                  'title': "您的动态收到了一条点赞",
                                },
                                'to': fcmToken,
                              };

                              var response = await http.post(url,
                                  headers: headers, body: jsonEncode(message));

                              if (response.statusCode == 200) {
                                print('Notification sent successfully.');
                              } else {
                                print(
                                    'Error1 sending notification: ${response.body}');
                              }
                            } catch (e) {
                              print('Error2 sending notification: $e');
                            }

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'likedPostsId':
                                  FieldValue.arrayUnion([widget.post.postuid])
                            });
                            // add likeCount to post
                            await FirebaseFirestore.instance
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
                            widget.isDetailed
                                ? Text('Like ${widget.post.likeCount}')
                                : const Text('Like'),
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
                        onPressed: () {
                          String text = widget.post.authorName +
                              "的动态：" +
                              widget.post.markdownText;
                          String subject = 'Sharing';

                          Share.share(text, subject: subject);
                        }, //TODO : 分享界面实现
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
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'favoritePostsId':
                                  FieldValue.arrayRemove([widget.post.postuid])
                            });
                            // update favoriteCount to post
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.post.postuid)
                                .update({
                              'favoriteCount': FieldValue.increment(-1),
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              'favoritePostsId':
                                  FieldValue.arrayUnion([widget.post.postuid])
                            });
                            // update favoriteCount to post
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.post.postuid)
                                .update({
                              'favoriteCount': FieldValue.increment(1),
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(widget.isFavorite
                                ? Icons.star
                                : Icons.star_border),
                            widget.isDetailed
                                ? Text('Favorite ${widget.post.favoriteCount}')
                                : const Text('Favorite'),
                            // Text('Favorite ${widget.post.favoriteCount}'),
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
