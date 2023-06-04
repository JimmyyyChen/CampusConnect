import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/user.dart';
import 'package:forum/infoinitial.dart';
import 'package:forum/message.dart';
import 'editProfilePage.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class AccountPage extends StatefulWidget {
  final bool loggedIn;

  const AccountPage({Key? key, required this.loggedIn, required this.localUser})
      : super(key: key);
  final UserData localUser;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // String _profile = ApplicationState().localUser.profileImage;
  // String _introduction = ApplicationState().localUser.introduction;
  var localUser = ApplicationState().localUser;
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.message,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MessagePage(msgList: ApplicationState().messages)));
                },
              ),
            ],
          ),
          body: Consumer<ApplicationState>(
              builder: (context, appState, _) => ListView(
                    children: [
                      GestureDetector(
                        onTap: () {},
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
                              image: NetworkImage(
                                appState.localUser.profileImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          appState.localUser.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          appState.localUser.introduction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
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
                                                          state
                                                              is UserCreated) {
                                                        var user = (state
                                                                is SignedIn)
                                                            ? state.user
                                                            : (state
                                                                    as UserCreated)
                                                                .credential
                                                                .user;
                                                        if (user == null) {
                                                          return;
                                                        }
                                                        if (state is SignedIn) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                        if (state
                                                            is UserCreated) {
                                                          //todo
                                                          //跳转到profile创建页面

                                                          appState.setLoggedIn(
                                                              true);
                                                          user.updateDisplayName(
                                                              user.email!.split(
                                                                  '@')[0]);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const EditProfilePage()),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }
                                                    })
                                                  ],
                                                )));
                                  }
                                },
                              )),
                      ListTile(
                        title: const Text('Edit Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfilePage()),
                          );
                          setState(() {
                            localUser = ApplicationState().localUser;
                          });
                          print("运行过setState()");
                        },
                      ),
                    ],
                  )));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            actions: [],
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
                                    builder: (context) =>
                                        const CustomSignInScreen()));
                          }
                        },
                      )),
            ],
          ));
    }
  }
}

class CustomSignInScreen extends StatelessWidget {
  const CustomSignInScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        AuthStateChangeAction((context, state) {
          if (state is SignedIn || state is UserCreated) {
            var user = (state is SignedIn)
                ? state.user
                : (state as UserCreated).credential.user;
            if (user == null) {
              return;
            }
            if (state is SignedIn) {
              Navigator.pop(context);
            }
            if (state is UserCreated) {
              //todo
              //跳转到profile创建页面
              user.updateDisplayName(user.email!.split('@')[0]);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InfoInitialPage()),
              );
              Navigator.pop(context);
            }
          }
        })
      ],
    );
  }
}
