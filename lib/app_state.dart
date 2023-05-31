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
  UserData localUser = UserData(
    uid: '0000001',
    name: "name",
    profileImage:
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
    introduction: "我的简介",
  );

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  void setLoggedIn(value) {
    _loggedIn = value;
  }

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

    // TODO: BUG
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(FirebaseAuth.instance.currentUser?.uid)
    //     .snapshots()
    //     .listen((DocumentSnapshot snapshot) {
    //   print("更新了");
    //   Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    //   localUser = UserData(
    //     uid: userData['uid'],
    //     name: userData['name'],
    //     profileImage: userData['profile'],
    //     introduction: userData['introduction'],
    //   );
    //   print(localUser.introduction);
    //   notifyListeners();
    // });

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
            if (document.data()['uid'] == user.uid) {
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
              postuid: document.id,
              authoruid: document.data()['authoruid'],
              fontColor: Color(document.data()['fontColor']),
              fontSize: document.data()['fontSize'],
              likeCount: document.data()['likeCount'],
              location: document.data()['location'],
              markdownText: document.data()['markdownText'],
              postTime: document.data()['postTime'],
              tag: document.data()['tag'],
              // imageFile: document.data()['pic'],
              // videoFile: document.data()['videos'],
              comments: [], // TODO
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
            print("更新啦");
            print(localUser.introduction);
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
}
