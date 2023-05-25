import 'package:flutter/material.dart';

import 'classes/post.dart';
import 'post_detail_page.dart';
import 'post_widget.dart';
import 'search_page.dart';
import 'new_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.posts, // post from everyone
    required this.follows, // current user's followings users
    required this.starPostsUID, // whether current user star this post
    required this.likePostsUID, // whether current user like this post
  });

  final List<Post> posts;
  final List<String> follows;
  final List<String> starPostsUID;
  final List<String> likePostsUID;

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
      body: ListView.builder(
          itemCount: widget.posts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return PostDetailPage(
                    post: widget.posts[index],
                    isStar: widget.starPostsUID
                        .contains(widget.posts[index].postId),
                    isLike: widget.likePostsUID
                        .contains(widget.posts[index].postId),
                    isUserFollowed:
                        widget.follows.contains(widget.posts[index].authorUID),
                  );
                }));
              },
              child: PostWidget(
                post: widget.posts[index],
                isStar:
                    widget.starPostsUID.contains(widget.posts[index].postId),
                isLike:
                    widget.likePostsUID.contains(widget.posts[index].postId),
                isUserFollowed:
                    widget.follows.contains(widget.posts[index].authorUID),
              ),
            );
          }),
    );
  }
}
