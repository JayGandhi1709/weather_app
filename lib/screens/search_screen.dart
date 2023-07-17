import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search...",
                suffix: searchController.text == ""
                    ? IconButton(
                        onPressed: () {
                          searchController.text = "";
                        },
                        icon: const Icon(Icons.close))
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
