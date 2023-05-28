import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'post_detail_page.dart';
import 'post_widget.dart';
import 'search_page.dart';
import 'new_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        // button for search
        actions: [
          IconButton(
            // route to search page
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPostPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => ListView.builder(
            itemCount: appState.posts.length,
            itemBuilder: (context, index) {
              String postUid = appState.posts.keys.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PostDetailPage(
                      postUid: postUid,
                    );
                  }));
                },
                child: PostWidget(
                  postUid: postUid,
                  authorUID: appState.posts[postUid]!.authorUID,
                  postTime: appState.posts[postUid]!.postTime,
                  content: appState.posts[postUid]!.content,
                  type: appState.posts[postUid]!.type,
                  isFollowed: appState.follows.contains(appState.posts[postUid]!.authorUID),
                  isFavorite: appState.favoritePostsId.contains(postUid),
                  isLike: appState.likedPostsId.contains(postUid),
                  comment: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return PostDetailPage(
                        postUid: postUid,
                      );
                    }));
                  },
                ),
              );
            }),
      ),
    );
  }
}
