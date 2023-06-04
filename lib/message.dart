import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forum/app_state.dart';
import 'package:forum/classes/msg.dart';

// class MessageList extends StatefulWidget {
//   MessageList(List<Map<String, String>> messages, {Key? key}) : super(key: key);
//   @override
//   _MessageListState createState() => _MessageListState();
// }

// class _MessageListState extends State<MessageList> {
//   @override
//   void initState() {
//     List<Map<String, String>> msgList = ApplicationState().messages;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       builder: (BuildContext context,
//           AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else {
//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic> message = snapshot.data![index];
//               return Card(
//                 // 添加 Card
//                 child: ListTile(
//                   title: Text(message['title']),
//                   subtitle: Text(message['body']),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

class MessagePage extends StatelessWidget {
  MessagePage({
    super.key,
    required this.msgList,
  });

  // final List<UserData> following; TODO
  final List<msg> msgList;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: ListView.builder(
        itemCount: msgList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            // 添加 Card
            child: ListTile(
              title: Text(msgList[index].title),
              subtitle: Text(msgList[index].content),
            ),
          );
        },
      ),
    );
  }
}
