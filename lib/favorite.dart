import 'dart:math';

import 'package:flutter/material.dart';

import 'search.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
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
      body: ListView.builder(
          itemCount: 9,
          itemBuilder: (context, index) {
            return PostWidget(
              isStar: true,
              post: Post(
                  userName: "userName",
                  userImage:
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                  time: '00:00',
                  text:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  images: List.filled(Random().nextInt(9) + 1,
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                  comments: [
                    const Comment(
                        userName: "commentUserName",
                        userImage:
                            "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                        time: "00:00",
                        text: "this is a comment"),
                    const Comment(
                        userName: "commentUserName",
                        userImage:
                            "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
                        time: "00:00",
                        text: "this is another comment")
                  ],
                  likes: 0),
            );
          }),
    );
  }
}

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
    this.isStar = false,
    this.isLike = false,
  });

  final Post post;
  final bool isStar;
  final bool isLike;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isStar = false;
  bool _isLike = false;

  @override
  void initState() {
    super.initState();
    _isStar = widget.isStar;
    _isLike = widget.isLike;
  }

  void _toggleStar() {
    setState(() {
      _isStar = !_isStar;
    });
  }

  void _toggleLike() {
    setState(() {
      _isLike = !_isLike;
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   _isStar = widget.isStar;
    //   _isLike = widget.isLike;
    // });

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return PostDetailPage(
            post: widget.post,
          );
        }));
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.post.userImage),
                  ),
                  Column(
                    children: [
                      Text(widget.post.userName),
                      Text(widget.post.time),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.post.text),
              ),
              // grid of images
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
                shrinkWrap: true,
                children: List.generate(widget.post.images.length, (index) {
                  return Image.network(widget.post.images[index]);
                }),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _toggleLike,
                    child: Row(
                      children: [
                        Icon(_isLike ? Icons.favorite : Icons.favorite_border),
                        const Text('Like'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.comment),
                        Text('Comment'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.share),
                        Text('Share'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleStar,
                    child: Row(
                      children: [
                        Icon(_isStar ? Icons.star : Icons.star_border),
                        const Text('Star'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Post {
  const Post({
    required this.userName,
    required this.userImage,
    required this.time,
    required this.text,
    required this.images,
    required this.comments,
    required this.likes,
  });

  final String userName;
  final String userImage;
  final String time;
  final String text;
  final List<String> images;
  final List<Comment> comments;
  final int likes;
}

class Comment {
  const Comment({
    required this.userName,
    required this.userImage,
    required this.time,
    required this.text,
  });

  final String userName;
  final String userImage;
  final String time;
  final String text;
}

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.userName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(post.userImage),
                    ),
                    Text(post.userName),
                    Text(post.time),
                    Text(post.text),
                    // grid of images
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                      shrinkWrap: true,
                      children: List.generate(post.images.length, (index) {
                        return Image.network(post.images[index]);
                      }),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Icon(Icons.thumb_up),
                              Text('Like'),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Icon(Icons.comment),
                              Text('Comment'),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Icon(Icons.share),
                              Text('Share'),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Icon(Icons.star),
                              Text('Star'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // commments view
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        return CommentWidget(
                          comment: post.comments[index],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            child:
                //  a input bar for comment
                Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.comment,
  });

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(comment.userImage),
            ),
            Column(
              children: [
                Text(comment.userName),
                Text(comment.time),
                Text(comment.text),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
