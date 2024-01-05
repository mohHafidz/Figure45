import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/Keranjang.dart';
import 'package:frontend/page/home.dart';
import 'package:frontend/page/profilepage.dart';
import 'package:frontend/page/search.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Layout extends StatefulWidget {
  Layout({Key? key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final PageController screens = PageController();
  bool shoppingCart = false;
  bool search = false;
  bool account = false;

  // Repository repository = Repository();

  // getData() async {
  //   listBarang = await repository.getData();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(132),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 20,
                  left: 50,
                ),
                child: IconButton(
                  onPressed: () {
                    screens.jumpToPage(0);
                    setState(() {
                      shoppingCart = false;
                      search = false;
                      account = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    'assets/Group 22.png',
                    height: 85,
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  top: 70,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Your search action here
                        screens.jumpToPage(1);
                        setState(() {
                          shoppingCart = false;
                          account = false;
                          search = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                      color: search ? Colors.red : Colors.black,
                      iconSize: 32,
                    ),
                    IconButton(
                      onPressed: () {
                        screens.jumpToPage(2);
                        setState(() {
                          shoppingCart = true;
                          account = false;
                          search = false;
                        });
                      },
                      icon: Icon(Icons.shopping_cart),
                      color: shoppingCart ? Colors.red : Colors.black,
                      iconSize: 32,
                    ),
                    IconButton(
                      onPressed: () {
                        screens.jumpToPage(3);
                        setState(() {
                          shoppingCart = false;
                          search = false;
                          account = true;
                        });
                      },
                      icon: const Icon(Icons.person),
                      color: account ? Colors.red : Colors.black,
                      iconSize: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: screens,
        children: [
          Home(),
          Search(),
          Keranjang(),
          ProfilePage(),
        ],
      ),
    );
  }
}
