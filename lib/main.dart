import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
return MaterialApp(
title: _title,
theme: ThemeData(
primarySwatch: Colors.purple,
textTheme: GoogleFonts.latoTextTheme(
Theme.of(context).textTheme,
),
),
home: MyStatefulWidget(),
);
}

}

class MyStatefulWidget extends StatefulWidget {
const MyStatefulWidget({super.key});

@override
State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> with SingleTickerProviderStateMixin {
int _selectedIndex = 0;
late AnimationController _controller;
late Animation<double> _animation;

static final List<Widget> _widgetOptions = <Widget>[
const HomePage(),
const FavoritePage(),
Consumer<ApplicationState>(
builder: (context, appState, _) => FollowingPage(
follows: appState.follows,
followingUsers: appState.followingUsers,
)),
Consumer<ApplicationState>(
builder: (context, appState, _) => UsersPage(
follows: appState.follows,
)),
Consumer<ApplicationState>(
builder: (context, appState, _) => AccountPage(
loggedIn: appState.loggedIn,
localUser: appState.localUser,
)),
];

@override
void initState() {
super.initState();
_controller = AnimationController(
duration: const Duration(milliseconds: 300),
vsync: this,
);
_animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(_controller);
}

void _onItemTapped(int index) {
_controller.forward().then((value) => _controller.reset());
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

if (state is UserCreated) {
//跳转到profile创建页面
user.updateDisplayName(user.email!.split('@')[0]);
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => const InfoInitialPage()),
);
}
}
})
],
);
}),

bottomNavigationBar: BottomNavigationBar(
items: <BottomNavigationBarItem>[
BottomNavigationBarItem(
icon: RotationTransition(
turns: _animation,
child: Icon(Icons.home),
),
label: 'Home',
),
BottomNavigationBarItem(
icon: RotationTransition(
turns: _animation,
child: Icon(Icons.star),
),
label: 'Favorites',
),
BottomNavigationBarItem(
icon: RotationTransition(
turns: _animation,
child: Icon(Icons.people_outline_sharp),
),
label: 'Following',
),
BottomNavigationBarItem(
icon: RotationTransition(
turns: _animation,
child: Icon(Icons.chat),
),
label: 'Chat',
),
BottomNavigationBarItem(
icon: RotationTransition(
turns: _animation,
child: Icon(Icons.account_circle),
),
label: 'Account',
),
],
currentIndex: _selectedIndex,
selectedItemColor: Colors.purple,
unselectedItemColor: Colors.black45,
onTap: _onItemTapped,
),
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}
}
