import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  const Post({
    required this.authorUID, 
    required this.content,
    required this.likes,
    required this.location,
    required this.pic,
    required this.postId,
    required this.postTime,
    required this.type,
    required this.videos,
    required this.comments,
  });

  final String authorUID;
  final String content;
  final int likes;
  final GeoPoint location;
  final String pic; // TODO: single image
  final String postId;
  final Timestamp postTime;
  final String type;
  final String videos; // TODO: single video
  final List<Comment> comments;

}

class Comment {
  const Comment({
    required this.commentTime,
    required this.content,
    required this.name,
    required this.profileImage, // TODO: firestore has different name
    required this.uID,
  });

  final Timestamp commentTime;
  final String content;
  final String name;
  final String profileImage;
  final String uID;
}
