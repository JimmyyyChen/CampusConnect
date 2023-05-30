import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';

class Post {
  const Post({
    required this.postuid,
    required this.authoruid,
    required this.markdownText,
    required this.likeCount,
    required this.postTime,
    required this.comments,
    required this.fontColor,
    required this.fontSize,
    this.tag,
    this.location,
    // required this.imageFile,
    // required this.videoFile,
  });

  final String postuid;
  final String authoruid;
  final String markdownText;
  final int likeCount;
  final Timestamp postTime;
  final List<Comment> comments;
  final double fontSize;
  final Color fontColor;
  final String? tag;
  final GeoPoint? location;
  // final String imageFile; // TODO: single image
  // final String videoFile; // TODO: single video
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
