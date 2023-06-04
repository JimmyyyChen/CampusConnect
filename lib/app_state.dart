import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'classes/post.dart';
import 'classes/user.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }
  //本地默认用户设置；
  UserData localUser = UserData(
    uid: '0000001',
    name: "name",
    profileImage:
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
    introduction: "我的简介",
  );

  List<UserData> _followingUsers = [];
  List<UserData> get followingUsers => _followingUsers;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  void setLoggedIn(value) {
    _loggedIn = value;
  }

  StreamSubscription<QuerySnapshot>? _usersSubscription;
  List<String> _follows = [];
  List<String> get follows => _follows;

  List<String> _blocks = [];
  List<String> get blocks => _blocks;

  List<String> _favoritePostsId = [];
  List<String> get favoritePostsId => _favoritePostsId;

  List<String> _likedPostsId = [];
  List<String> get likedPostsId => _likedPostsId;

  StreamSubscription<QuerySnapshot>? _postsSubscription;
  Map<String, Post> _posts = {};
  Map<String, Post> get posts => _posts;

  Map<String, UserData> _userMap = {};
  Map<String, UserData> get userMap => _userMap;

  Future<void> init() async {
    // TODO: BUG
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.data() == null) return;
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      localUser = UserData(
        uid: userData['uid'],
        name: userData['name'],
        profileImage: userData['profile'],
        introduction: userData['introduction'],
      );
      notifyListeners();
    });

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _usersSubscription = FirebaseFirestore.instance
            .collection('users')
            .snapshots()
            .listen((snapshot) {
          // get current user's followings list
          _follows = [];
          _favoritePostsId = [];
          _likedPostsId = [];
          _followingUsers = [];
          for (final document in snapshot.docs) {
            if (!_userMap.containsKey(document.data()['uid'])) {
              _userMap[document.data()['uid']] = UserData(
                uid: document.data()['uid'],
                name: document.data()['name'],
                profileImage: document.data()['profile'],
                introduction: document.data()['introduction'],
              );
            }
            print("userMap: $_userMap");

            if (document.data()['uid'] == user.uid) {
              for (final following in document.data()['follows']) {
                _follows.add(following);
                _followingUsers.add(_userMap[following]!);
                print("followingUsers: $_followingUsers");
              }

              for (final blocking in document.data()['blocks']) {
                _blocks.add(blocking);
              }
              print("follows: $_follows");
              print("blocks: $_blocks");
              for (final favoritePostId in document.data()['favoritePostsId']) {
                _favoritePostsId.add(favoritePostId);
              }
              for (final likedPostId in document.data()['likedPostsId']) {
                _likedPostsId.add(likedPostId);
              }
              break;
            }
          }
          notifyListeners();
        });

        _postsSubscription = FirebaseFirestore.instance
            .collection('posts')
            .snapshots()
            .listen((snapshot) async {
          _posts = {};
          for (final document in snapshot.docs) {
            // get author name from users collection by authoruid
            String authorName = await FirebaseFirestore.instance
                .collection('users')
                .doc(document.data()['authoruid'])
                .get()
                .then((snapshot) {
              return snapshot.data()?['name'];
            });

            _posts[document.id] = Post(
              postuid: document.id,
              authoruid: document.data()['authoruid'],
              authorName: authorName,
              fontColor: Color(document.data()['fontColor']),
              fontSize: document.data()['fontSize'],
              likeCount: document.data()['likeCount'],
              location: document.data()['location'],
              markdownText: document.data()['markdownText'],
              postTime: document.data()['postTime'],
              tag: document.data()['tag'],
              imageUrl: document.data()['image'],
              videoUrl: document.data()['video'],
              // comments: document.collection(comment)
              commentCount: document.data()['commentCount'],
              favoriteCount: document.data()['favoriteCount'],
            );
          }
          notifyListeners();
        });

        // get current user's info
        FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final document = snapshot.docs[0];
            localUser = UserData(
              uid: document.data()['uid'],
              name: document.data()['name'],
              profileImage: document.data()['profile'],
              introduction: document.data()['introduction'],
            );
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _follows = [];
        _favoritePostsId = [];
        _likedPostsId = [];
        _posts = {};
        _usersSubscription?.cancel();
        _postsSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  // void setToseeProfile(String s) {
  //   FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(s)
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       Map<String, dynamic> userData =
  //           documentSnapshot.data() as Map<String, dynamic>;
  //       toseeUser = UserData(
  //         uid: userData['uid'],
  //         name: userData['name'],
  //         profileImage: userData['profile'],
  //         introduction: userData['introduction'],
  //       );
  //     }
  //   }).catchError((error) {
  //     print('Error getting user data: $error');
  //   });
  // }
}
