import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class User {
  const User({required this.name, required this.id});

  final String name;
  final String id;
}

class ChatDetailPage extends StatelessWidget {
  const ChatDetailPage({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Center(
        child: Text('User ID: ${user.id}'),
      ),
    );
  }
}
