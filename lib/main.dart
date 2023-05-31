import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'favorite_page.dart';
import 'following_page.dart';
import 'account_page.dart';
import 'all_users.dart';
import 'infoinitial.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
  ]);
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const FavoritePage(),
    Consumer<ApplicationState>(
        builder: (context, appState, _) => FollowingPage(
              follows: appState.follows,
            )),
    const UsersPage(),
    Consumer<ApplicationState>(
        builder: (context, appState, _) => AccountPage(
              loggedIn: appState.loggedIn,
              localUser: appState.localUser,
            )),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ApplicationState>(builder: (context, appState, _) {
        if (appState.loggedIn) {
          return Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          );
        }
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

                // if (state is SignedIn) {
                  // Navigator.pop(context);
                // }
                if (state is UserCreated) {
                  //todo
                  //跳转到profile创建页面
                  user.updateDisplayName(user.email!.split('@')[0]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InfoInitialPage()),
                  );
                  // Navigator.pop(context);
                }
              }
            })
          ],
        );
      }),

      // body: Center(
      //   child: _widgetOptions.elementAt(_selectedIndex),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_sharp),
            label: 'Following',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black45,
        onTap: _onItemTapped,
      ),
    );
  }
}
