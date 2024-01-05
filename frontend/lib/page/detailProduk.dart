import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DetailProducts extends StatefulWidget {
  final int ID;
  DetailProducts({Key? key, required this.ID}) : super(key: key);
  @override
  State<DetailProducts> createState() => _DetailProductsState();
}

class _DetailProductsState extends State<DetailProducts> {
  List<Map<String, dynamic>> listBarang = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/${widget.ID}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> addKeranjang() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final url = Uri.parse('http://10.0.2.2:3000/user/addCart');
    final Map<String, dynamic> data = {
      'barangID': listBarang[0]['ID'],
      'email': user?.email ?? 'Email not available',
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        // Proses berhasil
      } else {
        // Proses gagal, tampilkan pesan kesalahan
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(context),
                  Container(
                    height: 1,
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(vertical: 12),
                  ),
                  if (listBarang.isNotEmpty)
                    buildDetailText(
                      listBarang[0]['namaBarang'],
                      fontSize: 16,
                      isBold: true,
                    ),
                  SizedBox(height: 8),
                  if (listBarang.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 1,
                      child: listBarang[0]['gambar'] != null
                          ? Image.network(
                              'http://10.0.2.2:3000/images/${listBarang[0]['gambar']}',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey,
                              child: Center(
                                child: Text('Image not available'),
                              ),
                            ),
                    ),
                  Container(
                    height: 1,
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(vertical: 12),
                  ),
                  buildDetailText('SIZE AND MATERIALS DETAILS', fontSize: 16),
                  SizedBox(height: 8),
                  if (listBarang.isNotEmpty)
                    buildDetailText(
                      listBarang[0]['deskripsi'],
                      fontSize: 14,
                    ),
                  Container(
                    height: 1,
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(vertical: 12),
                  ),
                  SizedBox(height: 10),
                  if (listBarang.isNotEmpty)
                    buildDetailText(
                      'MATERIAL: ${listBarang[0]['material']}',
                      fontSize: 14,
                    ),
                  SizedBox(height: 10),
                  if (listBarang.isNotEmpty)
                    buildDetailText(
                      'COLOR: ${listBarang[0]['warna']}',
                      fontSize: 14,
                    ),
                  SizedBox(height: 20),
                  if (listBarang.isNotEmpty) buildButtonsRow(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        Spacer(),
        Text(
          'DETAIL PRODUCT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Spacer()
      ],
    );
  }

  Widget buildDetailText(String text,
      {double fontSize = 14, bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: Colors.black,
      ),
    );
  }

  Widget buildButtonsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Center(
        child: TextButton(
          onPressed: () {
            // Add to Cart button functionality
            addKeranjang();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product success add to cart'),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          child: Text(
            '          ADD TO CART         ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
