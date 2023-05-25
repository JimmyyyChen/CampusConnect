import 'dart:math';

import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      // wechat style chat page
      body: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(users[Random().nextInt(users.length)].name),
                subtitle: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing eli...'),
                // profile image
                leading: CircleAvatar(
                  // backgroundColor: Colors.blue,
                  // random blue color
                  backgroundColor:
                      Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
                ),
                trailing: Text('10:00'),
                onTap: () {},
              ),
            );
          }),
    );
  }
}

class User {
  const User({required this.name, required this.id});

  final String name;
  final String id;
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
