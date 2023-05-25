import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'classes/post.dart';
import 'classes/user.dart';
import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }
  //本地默认用户设置；
  static UserData localUser = UserData(
    uID: "001",
    name: "name",
    profileImage:
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
    introduction: "我的简介",
  );

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _usersSubscription;
  List<String> _follows = [];
  List<String> get follows => _follows;

  List<String> _favoritePostsId = [];
  List<String> get favoritePostsId => _favoritePostsId;

  List<String> _likedPostsId = [];
  List<String> get likedPostsId => _likedPostsId;

  StreamSubscription<QuerySnapshot>? _postsSubscription;
  Map<String, Post> _posts = {};
  Map<String, Post> get posts => _posts;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

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
          for (final document in snapshot.docs) {
            if (document.data()['uID'] == user.uid) {
              for (final following in document.data()['follows']) {
                _follows.add(following);
              }
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
            .listen((snapshot) {
          _posts = {};
          for (final document in snapshot.docs) {
            _posts[document.id] = Post(
              authorUID: document.data()['authorUID'],
              content: document.data()['content'],
              likes: document.data()['likes'],
              location: document.data()['location'],
              pic: document.data()['pic'],
              postTime: document.data()['postTime'],
              type: document.data()['type'],
              videos: document.data()['videos'],
              comments: [], // TODO
            );
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _follows = [];
        _favoritePostsId = [];
        _likedPostsId = [];
        _usersSubscription?.cancel();
        _postsSubscription?.cancel();
      }
      notifyListeners();
    });
  }
}
