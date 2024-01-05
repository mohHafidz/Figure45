import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:frontend/page/account2.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _obscureText = true;

  Future<void> registerUser(String emailAddress, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(usernameController.text);
        // Registrasi berhasil
        // Anda bisa menambahkan logika lain atau navigasi ke halaman selanjutnya di sini
      }
      // Registrasi berhasil
      print('Registration successful: ${credential.user?.uid}');
      // Di sini Anda dapat melakukan navigasi ke halaman lain atau menampilkan pesan sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        // Tampilkan pesan bahwa password yang dimasukkan terlalu lemah
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Account already"),
              content: Text(
                  "Sorry, the email address you entered is already registered in our system"),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        print('The account already exists for that email.');
        // Tampilkan pesan bahwa akun sudah ada dengan email yang sama
      } else {
        print(e);
        // Tangani kode kesalahan lain jika diperlukan
      }
    } catch (e) {
      print(e);
      // Tangani kesalahan lainnya jika terjadi
    }
  }

  bool containsLettersAndNumbers(String value) {
    bool containsLetters = false;
    bool containsNumbers = false;

    for (var i = 0; i < value.length; i++) {
      if (value[i].toUpperCase() != value[i].toLowerCase()) {
        containsLetters = true;
      } else if (int.tryParse(value[i]) != null) {
        containsNumbers = true;
      }
    }

    return containsLetters && containsNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 45,
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 50,
            child: Image.asset(
              'assets/Group 22.png',
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          _buildInputField(
            label: 'Username',
            hint: 'Insert Your username',
            controller: usernameController,
            isPassword: false,
          ),
          SizedBox(
            height: 20,
          ),
          _buildInputField(
            label: 'Email',
            hint: 'Insert Your email',
            controller: emailController,
            isPassword: false,
          ),
          SizedBox(
            height: 20,
          ),
          _buildInputField(
            label: 'Password',
            hint: 'Insert Your Password',
            controller: passwordController,
            isPassword: true,
          ),
          SizedBox(
            height: 20,
          ),
          _buildInputField(
            label: 'Confirm password',
            hint: 'Insert Your confirm Password',
            controller: confirmPasswordController,
            isPassword: true,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isEmpty ||
                  passwordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty ||
                  emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Field can\'t be empty'),
                  ),
                );
              } else if (passwordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passwords do not match'),
                  ),
                );
              } else if (passwordController.text.length < 8 ||
                  !containsLettersAndNumbers(passwordController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Password must be more then 8 characters and contains a mixture of letters and numbers'),
                  ),
                );
              } else {
                // Panggil fungsi registerUser jika semua field terisi
                registerUser(
                  emailController.text,
                  passwordController.text,
                );
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
                'Sign Up',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
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
}
