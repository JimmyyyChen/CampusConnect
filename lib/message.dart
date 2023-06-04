import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late Future<List<Map<String, dynamic>>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _getMessages();
  }

  Future<List<Map<String, dynamic>>> _getMessages() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('messages').orderBy('timestamp', descending: true).get();

    // 先添加一条默认消息
    List<Map<String, dynamic>> messages = [{
      'title': '默认标题',
      'body': '默认消息内容',
    }];

    for (var doc in querySnapshot.docs) {
      messages.add(doc.data() as Map<String, dynamic>);
    }

    return messages;
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
