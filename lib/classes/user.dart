import 'post.dart';

// see users collection in firestore
class UserData {
  UserData({
    required this.uID,
    required this.name,
    this.introduction = '',
    this.posts = const [],
    this.profileImage = '',
    this.following = const [],
    this.followers = const [],
  });

  final String uID;
  final String name;
  final String introduction;
  final List<Post> posts;
  final String profileImage;
  final List<UserData> following;
  final List<UserData> followers;
}
