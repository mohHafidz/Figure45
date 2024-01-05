import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/card_keranjang.dart';
import 'package:http/http.dart' as http;

class Keranjang extends StatefulWidget {
  const Keranjang({Key? key}) : super(key: key);

  @override
  State<Keranjang> createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  List<Map<String, dynamic>> listBarang = [];
  List<Map<String, dynamic>> listBarang2 = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchData2();
  }

  void _updateData() {
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
        .get(Uri.parse('http://10.0.2.2:3000/user/keranjang/${user?.email}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchData2() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final response = await http
        .get(Uri.parse('http://10.0.2.2:3000/user/harga/${user?.email}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          listBarang2 = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Container(
          height: MediaQuery.of(context).size.height, // Tinggi maksimal layar
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(35),
                  child: Column(
                    children: [
                      Text(
                        'MY CART',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(
                        thickness: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                listBarang.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Tidak ada kartu',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listBarang.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 40,
                          childAspectRatio: 3.95,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Card_keranjang(
                            index: index,
                            updateProfileCallback: _updateData,
                          );
                        },
                      ),
                SizedBox(
                  height: 110,
                )
                // Other content inside the SingleChildScrollView
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: listBarang.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Handle the buy button press
                },
                backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  '     \$${listBarang2[0]['total_harga']}  ',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
