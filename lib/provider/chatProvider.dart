import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/msg.dart';

import '../constants/Firebase_constant.dart';

class ChatProvider {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Constructor
  ChatProvider() {
    configLocalNotification();
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');  // <--- Use the name of your notification icon file here
    DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      print(message.notification?.title);
      print(message.notification?.body);
      if (message.notification != null) {
        // Save the new message to the Firestore
        print("save message set");
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && message.notification != null) {
          final messageData = {
            'uid': user.uid,
            'title': message.notification!.title!,
            'body': message.notification!.body!,
          };

          FirebaseFirestore.instance.runTransaction((transaction) async {
            final docRef = FirebaseFirestore.instance.collection('messages').where('uid', isEqualTo: user.uid);
            final docSnapshot = await docRef.get();

            if (!docSnapshot.docs.isEmpty) {
              final document = docSnapshot.docs.first;
              final details = List.from(document.data()!['details'] ?? []);

              // Modify this line to add a dictionary containing both 'title' and 'body'
              details.add({'title': messageData['title'], 'body': messageData['body']});

              transaction.update(document.reference, {'details': details});
            } else {
              transaction.set(FirebaseFirestore.instance.collection('messages').doc(), {
                'uid': user.uid,
                'details': [{'title': messageData['title'], 'body': messageData['body']}],
              });
            }
          });
        }
        showNotification(message.notification!);
      }
    });


    firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null) {
        updateDataFirestore(FirestoreConstants.pathUserCollection,
            FirebaseAuth.instance.currentUser!.uid, {'pushToken': token});
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails("channel ID", "Aman",
            importance: Importance.high);
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }
}
