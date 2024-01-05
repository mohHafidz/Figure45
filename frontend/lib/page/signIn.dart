import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/layout.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        // Login berhasil
        // Anda bisa menambahkan logika lain atau navigasi ke halaman setelah login di sini
        print('Login berhasil: ${userCredential.user!.uid}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Wrong password"),
            content: Text("the password you entered is incorrect"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 45),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            child: Image.asset(
              'assets/Group 22.png',
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(height: 25),
          _buildInputField(
            label: 'Email',
            hint: 'Insert Your Email',
            controller: usernameController,
            isPassword: false,
          ),
          SizedBox(height: 20),
          _buildInputField(
            label: 'Password',
            hint: 'Insert Your Password',
            controller: passwordController,
            isPassword: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Field can\'t be empty'),
                  ),
                );
              } else {
                // Panggil fungsi registerUser jika semua field terisi
                _login();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFB10000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
              ),
              Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(
                    20), // Mengurangi padding agar border lebih terlihat
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Warna latar belakang tombol
                    onPrimary: Colors.black, // Warna teks tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    signInWithGoogle();
                  },
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Untuk mengatur ukuran sesuai isi
                    children: [
                      Image.asset(
                        'assets/google_2702602.png',
                        height: 50, // Mengurangi ukuran gambar
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isPassword,
  }) {
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
            alignment: isPassword ? Alignment.centerRight : Alignment.center,
            children: [
              TextField(
                controller: controller,
                obscureText: isPassword ? _obscureText : false,
                onChanged: (value) {
                  // Jika merupakan password, Anda tidak perlu melakukan apapun di sini
                },
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
              if (isPassword)
                IconButton(
                  onPressed: () {
                    setState(() {
                      // Tombol untuk mengubah _obscureText dan tampilan teks password
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      // Mengambil list akun Google yang tersedia di perangkat
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Jika ada lebih dari satu akun, tampilkan dialog pemilihan akun
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }

        final GoogleSignInAccount? selectedAccount =
            await _googleSignIn.signIn();

        if (selectedAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication =
              await selectedAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);
        }
      }
    } catch (e) {
      // Tangani kesalahan jika ada
    }
  }
}
