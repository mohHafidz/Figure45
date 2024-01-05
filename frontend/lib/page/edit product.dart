import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/page/layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

class EditProduct extends StatefulWidget {
  final int ID;
  const EditProduct({Key? key, required this.ID}) : super(key: key);

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController productName = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productColor = TextEditingController();
  final TextEditingController materialProduct = TextEditingController();
  Image? _imageWidget;
  List<Map<String, dynamic>> listBarang = [];
  final Color myCustomColor = Color(0xFFB10000);

  @override
  void initState() {
    fetchData(widget.ID);
    super.initState();
  }

  Future<File?> getImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return File(file.path);
  }

  Future<void> updateBarang(
    String productName,
    String productDescription,
    String productColor,
    String materialProduct,
    String productPrice,
  ) async {
    Map<String, dynamic> dataToSend = {
      'namaBarang': productName,
      'deskripsi': productDescription,
      'harga': productPrice,
      'warna': productColor,
      'material': materialProduct,
      'ID': widget.ID.toString(),
    };

    String jsonData = jsonEncode(dataToSend);

    String url = 'http://10.0.2.2:3000/admin/updateBarang';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      if (response.statusCode == 200) {
        // Proses berhasil
      } else {
        // Proses gagal, tampilkan pesan kesalahan
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error during registration: $e');
    }
  }

  Future<void> fetchData(int ID) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/admin/ambil/$ID'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          listBarang = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
        _initializeTextEditingControllers();
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> deleteBarang(int barangID) async {
    Map<String, dynamic> dataToSend = {
      'Id_barang': barangID,
    };

    String jsonData = jsonEncode(dataToSend);

    String url = 'http://10.0.2.2:3000/admin/delete';
    print(barangID);
    try {
      // Mengirim permintaan POST ke server dengan data JSON
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // Memeriksa status respons dari server
      if (response.statusCode == 200) {
        // Berhasil: Tindakan yang sesuai dengan respons dari server
        print('Data berhasil di hapus!');
      } else {
        // Gagal: Tangani kesalahan
        print('Gagal menghapus data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Tangani kesalahan jika terjadi kesalahan dalam proses permintaan
      print('Terjadi kesalahan: $error');
    }
  }

  void _initializeTextEditingControllers() {
    if (listBarang.isNotEmpty) {
      productName.text = listBarang[0]['namaBarang'];
      productDescription.text = listBarang[0]['deskripsi'] ?? '';
      productPrice.text = listBarang[0]['harga']?.toString() ?? '';
      productColor.text = listBarang[0]['warna'] ?? '';
      materialProduct.text = listBarang[0]['material'] ?? '';
      final imageUrl = listBarang[0]['gambar'] ?? '';
      fetchImage(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      Spacer(),
                      Text(
                        "EDIT PRODUCT",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildDivider(),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      GestureDetector(
                        child: _imageWidget != null
                            ? _imageWidget
                            : Icon(
                                Icons.add_photo_alternate,
                                size: 100,
                                color: Colors.black,
                              ),
                      ),
                      SizedBox(height: 10),
                      _buildInputField(productName, "PRODUCT NAME"),
                      _buildInputField(productPrice, "PRODUCT PRICE",
                          isNumeric: true),
                      _buildInputField(
                          productDescription, "PRODUCT DESCRIPTION",
                          maxLines: 5),
                      _buildInputField(productColor, "PRODUCT COLOR"),
                      _buildInputField(materialProduct, "MATERIAL PRODUCT"),
                    ],
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.0,
                          child: ElevatedButton(
                            onPressed: () => showConfirmationDelete(context),
                            style: ElevatedButton.styleFrom(
                              primary: myCustomColor,
                              onPrimary: Colors.white,
                            ),
                            child: Text(
                              "DELETE",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16), // Jarak antara dua tombol
                      Expanded(
                        child: SizedBox(
                          height: 48.0,
                          child: ElevatedButton(
                            onPressed: () => showConfirmationDialog(context),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 27, 135, 31),
                              onPrimary: Colors.white,
                            ),
                            child: Text(
                              "SAVE CHANGES",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.black,
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to save these changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateBarang(
                  productName.text,
                  productDescription.text,
                  productColor.text,
                  materialProduct.text,
                  productPrice.text,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Layout(),
                  ),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void showConfirmationDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to delete?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteBarang(listBarang[0]['ID']);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Layout(),
                  ),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1, bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: controller,
                keyboardType:
                    isNumeric ? TextInputType.number : TextInputType.text,
                inputFormatters: isNumeric
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ]
                    : null,
                maxLines: maxLines,
                onChanged: (value) {
                  // Do something if needed
                },
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> fetchImage(String imageUrl) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/images/$imageUrl'));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      setState(() {
        _imageWidget = Image.memory(imageBytes);
      });
    } else {
      throw Exception('Failed to load image');
    }
  }
}
