import 'dart:math';
import 'package:flutter/material.dart';
import 'chat_detail.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(user.name),
              subtitle: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing eli...'),
              leading: CircleAvatar(
                backgroundColor: Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
              ),
              trailing: Text('10:00'),
              onTap: () {
                // Navigate to the user detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(user: user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}



const List<User> users = [
  User(name: 'Elon Musk', id: 'realElonMusk'),
  User(name: 'Bill Gates', id: 'hiBillGates'),
  User(name: 'Jeff Bezos', id: 'amaaaaaaazon'),
  User(name: 'Mark Zuckerberg', id: 'markZuckerberg'),
  User(name: 'Tim Cook', id: 'timApple'),
  User(name: 'Sundar Pichai', id: 'sundarPichai'),
  User(name: 'Satya Nadella', id: 'satyaNadella'),
  User(name: 'Jack Dorsey', id: 'jackDorsey'),
  User(name: 'Larry Page', id: 'larryPage'),
  User(name: 'Sergey Brin', id: 'sergeyBrin'),
  User(name: 'Larry Ellison', id: 'larryEllison'),
  User(name: 'Steve Ballmer', id: 'steveBallmer'),
  User(name: 'Michael Dell', id: 'michaelDell'),
  User(name: 'Steve Jobs', id: 'steveJobs'),
  User(name: 'Ginni Rometty', id: 'ginniRometty'),
  User(name: 'Marissa Mayer', id: 'marissaMayer'),
];
