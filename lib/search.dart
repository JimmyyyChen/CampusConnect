import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    // search bar
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        // search bar
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search',
                ),
              ),
              // search button
              ElevatedButton(
                onPressed: () {},
                child: const Text('Search'),
              ),
            ],
          ),
        ));
  }
}
