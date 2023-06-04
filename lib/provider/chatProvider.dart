import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

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
    //Get FCM
    // FirebaseMessaging.instance.getToken().then((String? token) {
    //   if (token != null) {
    //     // Get new FCM registration token
    //     String msg = 'Token: $token';
    //
    //     // Log and toast
    //     print('Token: $token');
    //     Fluttertoast.showToast(
    //         msg: msg,
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         timeInSecForIosWeb: 1,
    //         backgroundColor: Colors.grey,
    //         textColor: Colors.white,
    //         fontSize: 16.0
    //     );
    //   } else {
    //     print('Fetching FCM registration token failed');
    //   }
    // }).catchError((e) {
    //   print('Fetching FCM registration token failed: $e');
    // });

    //listen channel
    //test mess

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      print(message.notification?.title);
      print(message.notification?.body);
      print("under is body");
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
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
