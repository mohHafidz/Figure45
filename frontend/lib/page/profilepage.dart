import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth.dart';
import 'package:frontend/page/account2.dart';
import 'package:frontend/page/addproduct.dart';
import 'package:frontend/page/card_like.dart';
import 'package:frontend/page/mycollection.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showSavedCards = true;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  List<Map<String, dynamic>> listBarang = [];
  List<Map<String, dynamic>> listBarang2 = [];
  void initState() {
    // TODO: implement initState
    fetchData();
    fetchData2();
    super.initState();
  }

  void _updateProfilePageData() {
    setState(() {
      // Panggil kembali fetchData atau metode yang diperlukan di sini
      fetchData();
      fetchData2();
    });
  }

  Future<void> fetchData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/user/like/${user?.email}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchData2() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/admin/${user?.email}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        listBarang2 = List<Map<String, dynamic>>.from(jsonResponse['data']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Tinggi maksimal layar
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Displaying username on the top left
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Displaying "@username"
                        Text(
                          user?.displayName ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 45, 45, 45),
                          ),
                        ),
                      ],
                    ),

                    // Logout button on the top right
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: const Color.fromARGB(255, 45, 45, 45),
                      ),
                      onPressed: () async {
                        signOut();
                      },
                    ),
                  ],
                ),

                SizedBox(
                  height: 30,
                ),

                // Add a horizontal line (Divider)
                Divider(
                  height: 5, // Adjusted height to reduce space
                  thickness: 2,
                  color: Colors.grey,
                ),

                // Container to move the entire row up
                Container(
                  // Adjust the top padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSavedCards = true;
                          });
                        },
                        child: Text(
                          'MY COLLECTION',
                          style: TextStyle(
                            color: showSavedCards
                                ? Colors.black
                                : Colors.grey[700],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          elevation: 0,
                        ),
                      ),

                      // Vertical line touching the horizontal divider
                      Container(
                        height:
                            30, // Adjust the height according to your design
                        width: 2,
                        color: Colors.grey,
                      ),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSavedCards = false;
                          });
                        },
                        child: Text(
                          'LIKED CARDS',
                          style: TextStyle(
                            color: showSavedCards
                                ? Colors.grey[700]
                                : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Saved Cards or Liked Cards content
                showSavedCards ? _buildSavedCards() : _buildLikedCards(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: showSavedCards
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType
                        .bottomToTop, // Ganti dengan jenis animasi yang diinginkan
                    duration: Duration(milliseconds: 500), // Durasi animasi
                    child: AddProduksA(),
                  ),
                );
                // Add your logic for the plus button here
                // For example, navigate to a new screen or show a modal
              },
              child: Icon(Icons.add,
                  color: const Color.fromARGB(255, 255, 255, 255)),
              shape: CircleBorder(),
              backgroundColor: Color.fromARGB(255, 244, 36, 36),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

// ...

  Widget _buildSavedCards() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount:
          listBarang2.length, // Replace with the actual number of saved cards
      itemBuilder: (context, index) {
        return MyCollection(
          index: index,
        );
      },
    );
  }

  Widget _buildLikedCards() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: listBarang.length, // Ubah jumlah item sesuai kebutuhan Anda
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.43,
      ),
      itemBuilder: (BuildContext context, int index) {
        return CardLike(
          index: index,
          updateProfileCallback: _updateProfilePageData,
        ); // Tampilkan Card2 di dalam GridView
      },
    );
  }
}
