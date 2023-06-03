import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class InfoInitialPage extends StatefulWidget {
  const InfoInitialPage({Key? key}) : super(key: key);

  @override
  _InfoInitialPageState createState() => _InfoInitialPageState();
}

class _InfoInitialPageState extends State<InfoInitialPage> {
  String currentUser =
      (FirebaseAuth.instance.currentUser as User).email.toString();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  String? _userName;
  String _imageUrl =
      'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80';
  String? _about;
  late File _image;

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageUrl = image.path;
        _image = File(_imageUrl);
        print(_imageUrl);
        print(_image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  // 处理点击事件的代码
                  print('Container clicked!');
                  _getImage();
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 10),
                      ),
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: NetworkImage(_imageUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                  hintText: 'Input Name',
                ),
                controller: displayNameController,
                keyboardType: TextInputType.name,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "About: ",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                ),
                controller: aboutController,
                //
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(" ",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () async {
                      _userName = displayNameController.text;
                      _about = aboutController.text;
                      print(_userName);
                      print(_about);
                      final String? uid =
                          FirebaseAuth.instance.currentUser?.uid;
                      print(uid);
                      String? token = await FirebaseMessaging.instance.getToken();
                      firebase_storage.Reference storageRef = firebase_storage
                          .FirebaseStorage.instance
                          .ref()
                          .child('profiles')
                          .child(uid!);
                      print(storageRef);
                      // await storageRef.putFile(File(_imageUrl));
                      UploadTask uploadTask =
                          storageRef.putFile(File(_imageUrl));
                      TaskSnapshot snap = await uploadTask;
                      String downloadurl = await snap.ref.getDownloadURL();
                      FirebaseFirestore.instance // TODO: change Uses model
                          .collection('users')
                          .doc(uid)
                          .set({
                        'name': _userName, //,yes I know.
                        'profile': downloadurl,
                        'uid': uid,
                        'introduction': _about,
                        'favoritePostsId': [],
                        'follows': [],
                        'likedPostsId': [],
                        'blocks': [],
                        'fcmToken':token,
                      });
                      print("sahngchuan");
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.black),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
