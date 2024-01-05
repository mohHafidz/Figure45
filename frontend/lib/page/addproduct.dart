import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/main.dart';
import 'package:frontend/page/layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

class AddProduksA extends StatefulWidget {
  @override
  State<AddProduksA> createState() => _AddProduksAState();
}

class _AddProduksAState extends State<AddProduksA> {
  final TextEditingController productName = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productColor = TextEditingController();
  final TextEditingController materialProduct = TextEditingController();
  final picker = ImagePicker();
  late File _selectedFile;
  Image? _imageWidget;

  Future<File?> getImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return File(file.path);
  }

  void _handleFileSelection() async {
    final result = await getImage();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.path);
        _imageWidget = Image.file(_selectedFile);
      });
    }
  }

  Future<void> addBarang(
    String productName,
    String productDescription,
    String productColor,
    String materialProduct,
    String productPrice,
    File imageFile,
  ) async {
    print(productName);
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    print(user?.email);
    final Uri url = Uri.parse('http://10.0.2.2:3000/admin/addbarang');
    final request = http.MultipartRequest('POST', url);
    request.fields['namaBarang'] = productName;
    request.fields['deskripsi'] = productDescription;
    request.fields['harga'] = productPrice;
    request.fields['warna'] = productColor;
    request.fields['material'] = materialProduct;
    request.fields['email'] = user?.email ?? "";

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _selectedFile.path,
      filename: Path.basename(_selectedFile.path),
    ));

    try {
      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        // Proses berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Layout(),
          ),
        );
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
                        "ADD PRODUCT",
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
                        onTap: _handleFileSelection,
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
                  SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: () => showConfirmationDialog(context),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 27, 135, 31),
                        onPrimary: Colors.white,
                      ),
                      child: Text(
                        "PUBLISH NOW!!!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
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
          content: Text("Are you sure you want to add this product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                addBarang(
                  productName.text,
                  productDescription.text,
                  productColor.text,
                  materialProduct.text,
                  productPrice.text,
                  _selectedFile,
                );
              },
              child: Text("Add"),
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
}
