import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageList extends StatefulWidget {
  final List<String> messageList;
  MessageList({Key?key,required this.messageList}) : super(key: key);
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late Future<List<Map<String, dynamic>>> _messagesFuture;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _messagesFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> message = snapshot.data![index];
              return Card( // 添加 Card
                child: ListTile(
                  title: Text(message['title']),
                  subtitle: Text(message['body']),
                ),
              );
            },
          );
        }
      },
    );
  }
}
