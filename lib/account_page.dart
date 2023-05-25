import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/infoinitial.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);
  // static bool isLogin = false;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: ListView(
          children: [
            Consumer<ApplicationState>(
                builder: (context, appState, _) => ListTile(
                      title: appState.loggedIn
                          ? Text(
                              'Hello, ${FirebaseAuth.instance.currentUser!.displayName}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            )
                          : const Text(
                              'You are not logged in.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                    )),
            Consumer<ApplicationState>(
                builder: (context, appState, _) => ListTile(
                      title: appState.loggedIn
                          ? const Text('Log Out')
                          : const Text('Log In'),
                      onTap: () {
                        if (appState.loggedIn) {
                          FirebaseAuth.instance.signOut();
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen(
                                        actions: [
                                          AuthStateChangeAction(
                                              (context, state) {
                                            if (state is SignedIn ||
                                                state is UserCreated) {
                                              var user = (state is SignedIn)
                                                  ? state.user
                                                  : (state as UserCreated)
                                                      .credential
                                                      .user;
                                              if (user == null) {
                                                return;
                                              }
                                              if (state is SignedIn) {
                                                Navigator.pop(context);
                                              }
                                              if (state is UserCreated) {
                                                //todo
                                                //跳转到profile创建页面
                                                user.updateDisplayName(
                                                    user.email!.split('@')[0]);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const EditProfilePage()),
                                                );
                                              }
                                            }
                                          })
                                        ],
                                      )));
                        }
                      },
                    )),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ));
  }
}
