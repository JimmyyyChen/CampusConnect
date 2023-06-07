import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/user.dart';
import 'package:forum/post_detail_page.dart';
import 'package:forum/post_widget.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<UserData> _foundedUsers = [];
  List<String> _foundedPostsUid = [];

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        // search bar
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<String> keywords = _controller.text.split(' ');
                  List<UserData> futureFoundedUsers = [];
                  List<String> futureFoundedPostsUid = [];

                  for (var keyword in keywords) {
                    // Search in users collection
                    await FirebaseFirestore.instance
                        .collection('users')
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        if (doc['name'].contains(keyword)) {
                          futureFoundedUsers.add(UserData(
                            uid: doc.id,
                            name: doc['name'],
                          ));
                        }
                      });
                    });

                    // Search in posts collection
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        if (doc['markdownText'].contains(keyword)) {
                          futureFoundedPostsUid.add(doc.id);
                        }
                        // if tag contains the keyword, tag is a String or null
                        if (doc['tag'] != null &&
                            doc['tag'].contains(keyword)) {
                          futureFoundedPostsUid.add(doc.id);
                        }
                        // if author is in the founded users
                        if (futureFoundedUsers
                            .map((e) => e.uid)
                            .contains(doc['authoruid'])) {
                          futureFoundedPostsUid.add(doc.id);
                        }
                      });
                    });
                  }

                  // Remove duplicates
                  futureFoundedUsers = futureFoundedUsers.toSet().toList();
                  futureFoundedPostsUid = futureFoundedPostsUid.toSet().toList();

                  setState(() {
                    _foundedUsers = futureFoundedUsers;
                    _foundedPostsUid = futureFoundedPostsUid;
                  });
                },
                child: const Text('Search'),
              ),

              Expanded(
                child: ListView(children: [
                  const ListTile(
                    title: Text('Users',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _foundedUsers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_foundedUsers[index].name),
                          onTap: () {},
                        );
                      }),
                  const ListTile(
                    title: Text('Posts',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _foundedPostsUid.length,
                      itemBuilder: (context, index) {
                        return Consumer<ApplicationState>(
                            builder: (context, appState, _) {
                              String postuid = _foundedPostsUid[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                        return PostDetailPage(
                                          postUid: postuid,
                                        );
                                      }));
                                },
                                child: PostWidget(
                                  showVideoThumbnail: true,
                                  hasBottomBar: false,
                                  post: appState.posts[postuid]!,
                                  isFavorite:
                                  appState.favoritePostsId.contains(postuid),
                                  isFollowed: appState.follows
                                      .contains(appState.posts[postuid]!.authoruid),
                                  isLike: appState.likedPostsId.contains(postuid),
                                  commentAction: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                          return PostDetailPage(
                                            postUid: postuid,
                                          );
                                        }));
                                  },
                                ),
                              );
                            });
                      }),
                ]),
              ),
            ],
          ),
        ));
  }
}