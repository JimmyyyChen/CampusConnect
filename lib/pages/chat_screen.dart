import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:forum/constants/Firebase_constant.dart';
import 'package:forum/constants/mediaquery.dart';
import 'package:forum/models/message_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:forum/constants/encryption.dart';
import 'package:forum/constants/chatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Chat_Screen extends StatefulWidget {
  final String uid;
  Chat_Screen({Key? key, required this.uid}) : super(key: key);
  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  String groupChatId = "";
  String currentUserId = "";
  String peerId = "";

  generateGroupId() {
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    peerId = widget.uid;

    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  sendChat({required String messaage}) async {
    final String encmess = messaage;
    // Encryption().encryption(messaage, "1234567891234567");
    MessageChat chat = MessageChat(
        content: encmess,
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: Timestamp.now().toString());

    // 将消息存储到 Firestore
    await FirebaseFirestore.instance
        .collection("groupMessages")
        .doc(groupChatId)
        .collection("messages")
        .add(chat.toJson());

    //发送通知
    try {
      var serverKey = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCsJPsj1KCy8JkaI+rviTRR80SkELA/ILsAX0PKKeHTfRxq9JdZ0o8TATOtjpUKg7wx+NjX20xZKAwhEivfQrBLT7j5AKZttEcuUIj4oLkdbey/lbTVBq3DAIVH+QKjG7SfXhtSeJpcwMP5PnoekevrSQ+GA2T+2LW19UrHvsLf5gSYVhyoxlVxh12LtkPUijjN47V/66kirJZ8s5NrlDKq3NGcff2npYrXaxbFXXjjdaBn/nxneX5zXAnqSROW2mIhz9gHXAudcgUT1lm5b0yo8qt+YKjVY6i0KkCBxa40S3cAOX+YzPY1stB1BiqHkWlDtdrxyU4neM6ufFCigmWJAgMBAAECggEASdira5mBPoH8C7ywwgUnzqf/ICqQkOQnlGdJm2YQHDulfzRh4QR0oAB5/NAXm6UbjIxl6WOIAw8s9NrouyPOoOAYR6lBu/oENxgRSicYgklvsFg2dNQiom6Mvm1R9kqiV2N1cRGPlo6TA08L8CVFAXAcGq9GGhU5Dk+lvr5UttsvVwLnDJxtVxxNEcZipnPuLJa/EitYTLfllMwb9fp/PWHO9S92G8eZm2NKMhQHgwpA2GRQGia8uOwHBXzL/FCh/UOJRJsiZ/LBX8e7WyBOcs+R0Dc8IG5vi27+z08CvgnX+qwHUpgMQiUcSQovMvEpXhOM/JdBU0GD9bqkOCLnaQKBgQDfJ8a/5oxwnKhTVnrE3yfvpCHAHCthS8k1C5O0jCshH8OzhIyPrOyoDqEG5xdg/6hpBIDgyAsMEzl8VRPBKQQZhDP9qSCtEqdh0e29hUfL3EFcs0Qa+hvvN1WKVr71ek82BGIepKlqYqICeODwaQ5zeg1/XBBKJMphTZ+6D+/oxwKBgQDFeyzWU0k6fBfXEbTj7x0mIzYYyNuhT/BO4MOj68pFUed86X/xCWdEaFUqbS2MQITTkK5kZq0yJXylbRuqrBQb8ZGFrtnRpcnqWbzNDruMf9ubifWPXwR82COHbzZFgrU6g5Jyr6H2j4r7a+MnPeMF927j/Prn58Z0mNarfZUPLwKBgQCG5oLNi0+m2+0dxA+fZ8+6nJwSiHTo8mmF+aOm531DHvKtWRmn2T+PMJjDlXualbJ3GdPXDtcuy4ha0wuIH4Vs73CGjXFFbxtklQWFJkcKw/F3Wp93N28fo3HAmUQDHZc47llqcNxBhbKuj+hbLQchY805CqyGRctaGxTN48iCDQKBgEuODt+JSfEYXT6pxZ2XdH2M5zugTXdwUC69i9yBcAgJiBmgdJTR1jK0ADGVR+HrJWaUakR7jDQtZ30bO4SXBbKTP+v3s9qkJZaF8tg5lMPyfyEJLWxHHD5vq1g70nXRxmi2wiciz0K4NKJw6p2u7dbwjfqoZY6ofKNLfoZqK8d9AoGAGHwGBozFX/+gQVQ0DyXvQhd5PBra+Xb5hnrUe4vhw8F6peCZtHsvF/Mc5X/5jmpRG0B7E7Rf3iaBsAT4wX8Tp+fObKHeB3Jqwe35YrvYxnWnN+RD6HQMkK27kECBEvjse3egGwS2TrDqemhdb3+IU7SXN35VHwcAwLRsnXrMjIw='; // 替换为您的Firebase服务器密钥
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: peerId)
          .get();

      var fcmToken = "eAdnWZ94Tr-ksrYsG7eM8i:APA91bEKvcM-J-5d5z6JRPdDwNu5VJQIDq8bDuC2X4crvtay7y0Jg0FestUUpoNr0lHQLysgh2f1sitx9droA3dT6L0U2JhNlCFdtrgSZyBA24dSaRAlrfunMG2j6-wV3TJK8MWo-txe";

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs[0].data();
        var fcmToken = userData['fcmToken'];
      }

      var message = {
        'notification': {
          'title': chat.content,
          'body': chat.content,
        },
        'to': fcmToken,
      };

      var response = await http.post(url, headers: headers, body: jsonEncode(encmess));

      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Error sending notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
    
    _messageController.text = "";

  }

  @override
  void initState() {
    generateGroupId();
    _scrollDown();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _controller = ScrollController();

  void _scrollDown() {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  Future<bool> onBackPress() {
    updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: null},
    );
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                onBackPress();
              }),
          title: const Text("Your Chats"),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: 60,
            width: media(context).width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      // pickImage();
                    },
                    icon: Icon(Icons.image)),
                IconButton(onPressed: () {}, icon: Icon(Icons.person)),
                Container(
                  width: media(context).width / 2,
                  child: TextField(
                    decoration: InputDecoration(label: Text("Enter message")),
                    controller: _messageController,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      sendChat(messaage: _messageController.text);
                      _messageController.text = "";
                      _scrollDown();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("groupMessages")
                .doc(groupChatId)
                .collection("messages")
                .orderBy(FirestoreConstants.timestamp, descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                reverse: true,
                shrinkWrap: true,
                controller: _controller,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  MessageChat chat =
                  MessageChat.fromDocument(snapshot.data!.docs[index]);
                  final String message = chat.content;
                  // Encryption().decrypted(chat.content, "1234567891234567");
                  return ChatBubble(
                      text: chat.content,
                      isCurrentUser:
                      chat.idFrom == currentUserId ? true : false);
                },
              );
            }),
      ),
    );
  }
}
