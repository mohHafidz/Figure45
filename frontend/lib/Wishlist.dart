import 'package:flutter/material.dart';

void main() => runApp(const wishlist());

class wishlist extends StatelessWidget {
  const wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        body: const Center(
          child: Text('Hello wishlist'),
        ),
      ),
    );
  }
}
