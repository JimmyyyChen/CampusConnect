import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';

class Post {
  const Post({
    required this.postuid,
    required this.authoruid,
    required this.markdownText,
    required this.likeCount,
    required this.postTime,
    required this.commentCount,
    required this.favoriteCount,
    required this.fontColor,
    required this.fontSize,
    this.tag,
    this.location,
    required this.imageUrl,
    required this.videoUrl,
    required this.authorName, 
  });

  final String postuid;
  final String authoruid;
  final String markdownText;
  final int likeCount;
  final Timestamp postTime;
  final int commentCount;
  final int favoriteCount;
  final double fontSize;
  final Color fontColor;
  final String? tag;
  final GeoPoint? location;
  final String? imageUrl; // TODO: single image
  final String? videoUrl; // TODO: single video
  final String authorName;
}

class Comment {
  const Comment({
    required this.uid,
    required this.authorUid,
    required this.commentTime,
    required this.content,
  });

  final String uid;
  final String authorUid;
  final Timestamp commentTime;
  final String content;
}
