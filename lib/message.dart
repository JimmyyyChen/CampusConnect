import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/msg.dart';

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
          title: Text('User Details'),
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
            List<dynamic> details = snapshot.data?.docs.first['details'] ?? [];
            return ListView.builder(
              itemCount: details.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(details[index]),
                );
              },
            );
          },
        ),
      );
    }
  }
}