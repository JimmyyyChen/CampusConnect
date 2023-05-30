import 'dart:developer';
import 'dart:typed_data';

import 'package:forum/constants/Firebase_constant.dart';
import 'package:forum/constants/mediaquery.dart';
import 'package:forum/models/message_chat.dart';
import 'package:forum/constants/encryption.dart';
import 'package:forum/constants/chatBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


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

    await FirebaseFirestore.instance
        .collection("groupMessages")
        .doc(groupChatId)
        .collection("messages")
        .add(chat.toJson());

    _messageController.text = "";
    //
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
