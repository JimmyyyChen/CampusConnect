import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'classes/post.dart';
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
  int _sortMode = 0; // 0: sort by time, 1: sort by likes, 2: sort by comments
  int _filterMode = 0; // 0: all, 1: following, 2: 校园资讯, 3: 二手交易

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
      body: Column(
        children: [
          SafeArea(
            // choose sort mode and filter mode using 2 dropdown button
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                  value: _sortMode,
                  onChanged: (value) {
                    setState(() {
                      _sortMode = value as int;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text("时间排序"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("点赞排序"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("评论排序"),
                    ),
                  ],
                ),
                DropdownButton(
                  value: _filterMode,
                  onChanged: (value) {
                    setState(() {
                      _filterMode = value as int;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text("所有帖子"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("关注的人"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("校园资讯"),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text("二手交易"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) {
                // make a copy of appState.posts
                Map<String, Post> posts = Map.from(appState.posts);
                // sort the posts

                posts = Map.fromEntries(posts.entries.toList()
                  ..sort((e1, e2) =>
                      e2.value.postTime.compareTo(e1.value.postTime)));
                if (_sortMode == 1) {
                  posts = Map.fromEntries(posts.entries.toList()
                    ..sort((e1, e2) =>
                        e2.value.likeCount.compareTo(e1.value.likeCount)));
                } else if (_sortMode == 2) {
                  posts = Map.fromEntries(posts.entries.toList()
                    ..sort((e1, e2) => e2.value.commentCount
                        .compareTo(e1.value.commentCount)));
                }

                return ListView.builder(
                  itemCount: appState.posts.length,
                  itemBuilder: (context, index) {
                    String postuid = posts.keys.elementAt(index);
                    print("是否屏蔽");
                    print(appState.posts[postuid]!.authoruid);
                    print(appState.blocks);
                    if (appState.blocks
                        .contains(appState.posts[postuid]!.authoruid)) {
                      print("屏蔽你");
                      return Container();
                    }
                    if (_filterMode == 1 &&
                        !appState.follows
                            .contains(appState.posts[postuid]!.authoruid)) {
                      return const SizedBox.shrink();
                    }

                    if (_filterMode == 2 &&
                        appState.posts[postuid]!.tag != "校园资讯") {
                      return const SizedBox.shrink();
                    }

                    if (_filterMode == 3 &&
                        appState.posts[postuid]!.tag != "二手交易") {
                      return const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return PostDetailPage(
                            postUid: postuid,
                          );
                        }));
                      },
                      child: PostWidget(
                        showVideoThumbnail: true,
                        post: appState.posts[postuid]!,
                        isFavorite: appState.favoritePostsId.contains(postuid),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
