import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/detailProduk.dart';
import 'package:frontend/page/profilepage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

typedef UpdateProfileCallback = void Function();

class CardLike extends StatefulWidget {
  final int index;
  final UpdateProfileCallback updateProfileCallback;
  CardLike({Key? key, required this.index, required this.updateProfileCallback})
      : super(key: key);

  @override
  State<CardLike> createState() => _CardLikeState();
}

class _CardLikeState extends State<CardLike> {
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

  Future<void> deleteLike() async {
    final String nama = listBarang[widget.index]['namaBarang'];
    final response = await http.post(Uri.parse(
        'http://10.0.2.2:3000/user/deleteLike/${listBarang[widget.index]['ID']}'));
    if (response.statusCode == 200) {
      await fetchData();
      widget.updateProfileCallback();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(nama + " Removed from like list"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(listBarang[widget.index]['ID']);
    if (listBarang.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Center(
          child: Text(
            'Keranjang anda masih kosong',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15, // You can adjust the font size as needed
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ); // Placeholder widget while loading data
    } else {
      return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(
                top: 5,
                right: 10,
              ),
              child: IconButton(
                onPressed: () {
                  showConfirmationDialog(context);
                },
                icon: Icon(Icons.favorite_sharp),
                color: Colors.red,
              ),
            ),
            Expanded(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                listBarang[widget.index]['namaBarang'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
              child: Text(
                listBarang[widget.index]['deskripsi'],
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.53),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: Row(
                children: [
                  Text(
                    '\$${listBarang[widget.index]['harga']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  Container(
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(
                      top: 5,
                      right: 10,
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "CART",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: myCustomColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<http.Response> fetchImage(String imageUrl) async {
    print(imageUrl);
    final response = await http.get(Uri.parse(
        'http://10.0.2.2:3000/images/$imageUrl')); // Ganti dengan URL server Anda
    return response;
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text(
              "Are you sure you want to delete this product from like list?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteLike();
                Navigator.pop(context);
              },
              child: Text("ok"),
            ),
          ],
        );
      },
    );
  }
}
