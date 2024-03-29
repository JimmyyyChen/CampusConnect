import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/user.dart';

import 'package:forum/profile_page.dart';

class FollowingPage extends StatelessWidget {
  FollowingPage({
    super.key,
    required this.follows,
    required this.followingUsers,
  });

  // final List<UserData> following; TODO
  final List<String> follows;
  final List<UserData> followingUsers;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Following')),
      body: ListView.builder(
          itemCount: followingUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(followingUsers[index].name),
              subtitle: Text(followingUsers[index].introduction),
              // title: Text(users[index].id), TODO
              // subtitle: Text(users[index].name),
              // profile image
              leading: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: follows[index]),
                      ));
                },
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage:
                      //todo
                      NetworkImage(followingUsers[index].profileImage),
                  child: Container(),
                ),
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
