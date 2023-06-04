import 'package:forum/pages/chat_screen.dart';
import 'package:forum/provider/chatProvider.dart';
import 'package:forum/classes/user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class UsersPage extends StatefulWidget {
  final List<String> follows;
  UsersPage({
    super.key,
    required this.follows,
  });
  @override
  State<UsersPage> createState() => _UsersPageState();

}



class _UsersPageState extends State<UsersPage> {
  ChatProvider chatProvider = ChatProvider();
  @override
  void initState() {
    chatProvider.registerNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("this uid is" +FirebaseAuth.instance.currentUser!.uid);
    //test mess

    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: <Widget>[
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: widget.follows) // 使用whereIn来选择包含在follows列表中的用户
              .snapshots(),
          builder: ((context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("snapshot.connectionState == ConnectionState.waiting");
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              print("!snapshot.hasDatag");
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                UserData user = UserData(uid: snapshot.data!.docs[index].data()['uid'], name: snapshot.data!.docs[index].data()['name']);
                // UserData user = UserData.fromJson(snapshot.data!.docs[index]);

                return InkWell(
                  autofocus: true,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat_Screen(uid: user.uid),
                        ));
                  },
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.uid),
                  ),
                );
              },
            );
          })),
    );
  }
}
