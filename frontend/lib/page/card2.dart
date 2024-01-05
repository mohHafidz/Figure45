import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/detailProduk.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class Card2 extends StatefulWidget {
  final int index;
  bool liked;
  Card2({Key? key, required this.index, required this.liked}) : super(key: key);

  @override
  State<Card2> createState() => _Card2State();
}

class _Card2State extends State<Card2> {
  final Color myCustomColor = Color(0xFFB10000);
  List<Map<String, dynamic>> listBarang = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> like(int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final url = Uri.parse('http://10.0.2.2:3000/user/like');
    final Map<String, dynamic> data = {
      'barangID': listBarang[index]['ID'],
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

  Future<void> addKeranjang(int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final url = Uri.parse('http://10.0.2.2:3000/user/addCart');
    final Map<String, dynamic> data = {
      'barangID': listBarang[index]['ID'],
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

  // Future<void> suka() async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user = auth.currentUser;
  //   Map<String, dynamic> dataToSend = {
  //     'barangID': listBarang[0]['barangID'],
  //     'email': user?.email,
  //   };

  //   String jsonData = jsonEncode(dataToSend);

  //   String url = 'http://10.0.2.2:3000/user/liked';

  //   try {
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonData,
  //     );
  //     if (response.statusCode == 200) {
  //       // Proses berhasil
  //       setState(() {
  //         liked = true;
  //       });
  //       print('ada data');
  //     } else {
  //       // Proses gagal, tampilkan pesan kesalahan
  //     }
  //   } catch (e) {
  //     // Tangani kesalahan jika terjadi
  //     print('Error during registration: $e');
  //   }
  // }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
      }
      // suka();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.liked);
    if (listBarang.isEmpty) {
      return CircularProgressIndicator(); // Placeholder widget while loading data
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
              child: TextButton(
                onPressed: () {
                  // Handle button press
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType
                          .fade, // Ganti dengan jenis animasi yang diinginkan
                      duration: Duration(milliseconds: 500), // Durasi animasi
                      child: DetailProducts(ID: listBarang[widget.index]['ID']),
                    ),
                  );
                },
                child: Text(
                  "BUY",
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
                  IconButton(
                    onPressed: () {
                      like(widget.index);
                      setState(() {
                        widget.liked = true;
                      });
                    },
                    icon: widget.liked
                        ? Icon(Icons.favorite_sharp)
                        : Icon(Icons.favorite_border_rounded),
                    // icon: Icon(Icons.favorite_border_rounded),
                    color: Colors.red,
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
}
