import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// see users collection in firestore
class UserData {
  final String uid;
  final String name;
  final String introduction;
  final List<Post> posts;
  final String profileImage;
  final List<UserData> following;
  final List<UserData> followers;

  UserData({
    required this.uid,
    required this.name,
    this.introduction = '',
    this.posts = const [],
    this.profileImage = '',
    this.following = const [],
    this.followers = const [],
  });
}
