import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'post_detail_page.dart';
import 'post_widget.dart';
import 'search_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
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
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => appState.favoritePostsId.isEmpty
            ? const Center(
                child: Text("No favorite posts"),
              )
            : ListView.builder(
                itemCount: appState.posts.length,
                itemBuilder: (context, index) {
                  if (!appState.favoritePostsId
                      .contains(appState.posts.keys.elementAt(index))) {
                    return const SizedBox.shrink();
                  }
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
                      showVideoThumbnail: true,
                      post: appState.posts[postUid]!,
                      isFavorite: appState.favoritePostsId.contains(postUid),
                      isFollowed: appState.follows
                          .contains(appState.posts[postUid]!.authoruid),
                      isLike: appState.likedPostsId.contains(postUid),
                      commentAction: () {
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
