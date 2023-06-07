import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/msg.dart';
import 'package:forum/pages/chat_screen.dart';
import 'package:forum/post_detail_page.dart';

class DetailsScreen extends StatelessWidget {
  DetailsScreen();
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('No user signed in'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('消息记录'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('messages').where('uid', isEqualTo: user.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            List<dynamic> details = [];
            if (snapshot.data?.docs.isNotEmpty == true) {
              details = snapshot.data!.docs.first['details'] ?? [];
            }
            return ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${details[index]['title']} - ${details[index]['body']}'),
                  onTap: () {
                    // 在这里处理点击事件
                    print('Message tapped: ${details[index]['title']} - ${details[index]['body']}');
                    if (details[index]['title'] == '您的动态收到了一条点赞' || details[index]['title'] == '您收到了一条评论' || details[index]['title'] == '您的动态收到了一条回复') {
                      print('点赞评论回复');
                    } else {
                      // handle the situation when the string does not contain space
                      final uid = details[index]['body'].split(' ')[1];
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => Chat_Screen(uid: uid),
                      ));

                }
                      print('The detail string does not contain space');
                    }
                );
              },
            );

          },
        ),
      );
    }
  }
}
