import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class FollowingPage extends StatelessWidget {
  FollowingPage({
    super.key,
    required this.follows,
  });

  // final List<UserData> following; TODO
  final List<String> follows;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: ListView.builder(
          itemCount: follows.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(follows[index]),
              subtitle: Text("subtitle"),
              // title: Text(users[index].id), TODO
              // subtitle: Text(users[index].name),
              // profile image
              leading: CircleAvatar(
                // backgroundColor: Colors.blue,
                // random blue color
                backgroundColor:
                    Color(0xFF0000FF & Random().nextInt(0xFFFFFFFF)),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('取消关注'),
                          content: const Text('确定要取消关注吗？'),
                          actions: [
                            TextButton(
                              child: const Text('取消'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('确定'),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'follows':
                                      FieldValue.arrayRemove([follows[index]])
                                });

                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16),
                    Text('已关注',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onTap: () {},
            );
          }),
    );
  }
}



// for testing
// class User {
//   const User({required this.name, required this.id});

//   final String name;
//   final String id;
// }

// const List<User> users = [
//   User(name: 'Elon Musk', id: 'realElonMusk'),
//   User(name: 'Bill Gates', id: 'hiBillGates'),
//   User(name: 'Jeff Bezos', id: 'amaaaaaaazon'),
//   User(name: 'Mark Zuckerberg', id: 'markZuckerberg'),
//   User(name: 'Tim Cook', id: 'timApple'),
//   User(name: 'Sundar Pichai', id: 'sundarPichai'),
//   User(name: 'Satya Nadella', id: 'satyaNadella'),
//   User(name: 'Jack Dorsey', id: 'jackDorsey'),
//   User(name: 'Larry Page', id: 'larryPage'),
//   User(name: 'Sergey Brin', id: 'sergeyBrin'),
//   User(name: 'Larry Ellison', id: 'larryEllison'),
//   User(name: 'Steve Ballmer', id: 'steveBallmer'),
//   User(name: 'Michael Dell', id: 'michaelDell'),
//   User(name: 'Steve Jobs', id: 'steveJobs'),
//   User(name: 'Ginni Rometty', id: 'ginniRometty'),
//   User(name: 'Marissa Mayer', id: 'marissaMayer'),
// ];