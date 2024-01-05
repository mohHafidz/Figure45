import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef UpdateProfileCallback = void Function();

class Card_keranjang extends StatefulWidget {
  final int index;
  final UpdateProfileCallback updateProfileCallback;
  Card_keranjang(
      {Key? key, required this.index, required this.updateProfileCallback})
      : super(key: key);

  @override
  State<Card_keranjang> createState() => _Card_keranjangState();
}

class _Card_keranjangState extends State<Card_keranjang> {
  List<Map<String, dynamic>> listBarang = [];

  @override
  void initState() {
    super.initState();
    fetchData();
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

  Future<void> plusCart(int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final url = Uri.parse('http://10.0.2.2:3000/user/plusCart');
    final Map<String, dynamic> data = {
      'cartID': listBarang[index]['cartID'],
      'email': user?.email ?? 'Email not available',
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Jika proses berhasil, panggil fetchData lagi untuk memperbarui data
        await fetchData();
        widget.updateProfileCallback();
      } else {
        // Proses gagal, tampilkan pesan kesalahan
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error during registration: $e');
    }
  }

  Future<void> minusCart(int index) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    final url = Uri.parse('http://10.0.2.2:3000/user/minusCart');
    final Map<String, dynamic> data = {
      'cartID': listBarang[index]['cartID'],
      'email': user?.email ?? 'Email not available',
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // Jika proses berhasil, panggil fetchData lagi untuk memperbarui data
        await fetchData();
        widget.updateProfileCallback();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.2,
          child: FutureBuilder<http.Response>(
            future: fetchImage(listBarang[widget.index]['gambar']),
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data!.statusCode == 200) {
                  return Image.memory(snapshot.data!.bodyBytes);
                } else {
                  return Placeholder(); // Tampilkan placeholder atau pesan kesalahan jika gagal
                }
              } else {
                return CircularProgressIndicator(); // Tampilkan loader atau indikator loading
              }
            },
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listBarang[widget.index]['namaBarang'],
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Container(
              width: 150,
              child: Text(
                listBarang[widget.index]['deskripsi'],
                style: TextStyle(fontSize: 10, color: Colors.black),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${listBarang[widget.index]['harga']}',
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            InkWell(
              onTap: () {
                // Ketika tombol 'Tambah' ditekan, panggil fungsi untuk menambah jumlah barang
                plusCart(widget.index);
                setState(() {
                  // Setelah menambah jumlah barang, perbarui jumlah yang ditampilkan
                  listBarang[widget.index]['jumlah']++;
                });
              },
              child: Container(
                width: 23.0,
                height: 23.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 177, 0, 0),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              '${listBarang[widget.index]['jumlah']}',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {
                // Add your logic to decrease quantity
                minusCart(widget.index);
                setState(() {
                  // Setelah menambah jumlah barang, perbarui jumlah yang ditampilkan
                  listBarang[widget.index]['jumlah']--;
                });
              },
              child: Container(
                width: 23.0,
                height: 23.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 177, 0, 0),
                ),
                child: Center(
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<http.Response> fetchImage(String imageUrl) async {
    print(imageUrl);
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/images/$imageUrl'));
    return response;
  }
}
