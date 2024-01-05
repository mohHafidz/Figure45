import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/page/card2.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> listBarang = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
          for (var i = 0; i < listBarang.length; i++) {
            listBarang[i]['liked'] = false; // Inisialisasi liked dengan false
          }
        });
        for (var i = 0; i < listBarang.length; i++) {
          await suka(i); // Panggil fungsi suka untuk setiap index
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> suka(int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    Map<String, dynamic> dataToSend = {
      'barangID': listBarang[index]['ID'],
      'email': user?.email,
    };

    String jsonData = jsonEncode(dataToSend);

    String url = 'http://10.0.2.2:3000/user/liked';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      if (response.statusCode == 200) {
        print('Data ini di-like');
        setState(() {
          listBarang[index]['liked'] = true;
        });
      } else {
        setState(() {
          listBarang[index]['liked'] = false;
        });
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < listBarang.length; i++) {
      print(listBarang[i]['liked']); // Panggil fungsi suka untuk setiap index
    }
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textProportion = 0.05; // Proporsi teks terhadap lebar layar
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildNavButton('BUY ', FontWeight.bold),
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  buildNavButton(' DISCOVER ', null),
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  buildNavButton(' COLLECT', FontWeight.bold),
                ],
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: [
                Image.asset('assets/iklan 1.jpg'),
                Image.asset('assets/iklan 2.jpg'),
                Image.asset('assets/Artboard 1.png'),
                Image.asset('assets/Artboard 2.png'),
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: i,
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(
              height: 20,
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: listBarang.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.43,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Card2(
                  index: index,
                  liked: listBarang[index]['liked'] ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun tombol navigasi
  Widget buildNavButton(String text, FontWeight? fontWeight) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textProportion = 0.066; // Proporsi teks terhadap lebar layar
    final fontSize = screenWidth * textProportion;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
