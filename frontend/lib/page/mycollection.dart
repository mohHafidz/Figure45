import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/edit%20product.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class MyCollection extends StatefulWidget {
  final int index;
  const MyCollection({Key? key, required this.index}) : super(key: key);

  @override
  State<MyCollection> createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> {
  final Color myCustomColor = Color(0xFFB10000);
  List<Map<String, dynamic>> listBarang = [];
  void initState() {
    // TODO: implement initState
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/admin/${user?.email}'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle the tap on the container here
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType
                .bottomToTop, // Ganti dengan jenis animasi yang diinginkan
            duration: Duration(milliseconds: 500), // Durasi animasi
            child: EditProduct(ID: listBarang[widget.index]['ID']),
          ),
        );
        // You can add your navigation logic or any other action here
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 32, 32, 32),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 100.0), // Adjust the top padding as needed
              child: Center(
                child: Transform.scale(
                  scale: 3.7,
                  child: FutureBuilder<http.Response>(
                    future: fetchImage(listBarang[widget.index]['gambar']),
                    builder: (BuildContext context,
                        AsyncSnapshot<http.Response> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        if (snapshot.data!.statusCode == 200) {
                          // Tampilkan gambar jika berhasil diambil
                          return Image.memory(snapshot.data!.bodyBytes);
                        } else {
                          // Tampilkan placeholder atau pesan kesalahan jika gagal
                          return Placeholder(); // Ganti dengan widget yang sesuai
                        }
                      } else {
                        // Tampilkan loader atau indikator loading
                        return CircularProgressIndicator(); // Ganti dengan widget yang sesuai
                      }
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10.0,
              left: 10.0,
              child: Text(
                listBarang[widget.index]['namaBarang'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> fetchImage(String imageUrl) async {
    print(imageUrl);
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:3000/images/$imageUrl')); // Ganti dengan URL server Anda
    return response;
  }
}
