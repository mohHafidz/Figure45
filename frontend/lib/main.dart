import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/page/account2.dart';
import 'package:frontend/page/addproduct.dart';
import 'package:frontend/page/detailProduk.dart';
import 'package:frontend/page/layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCl70-TW01VQ_1676xgQ8bKa32xxrWrjeo",
            appId: "1:664677924702:android:b995b174f97af3145459cf",
            messagingSenderId: "664677924702",
            projectId: "figure45-e5a43",
          ),
        )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapShot) {
            if (snapShot.hasError) {
              return Text(
                  snapShot.error.toString()); // Menampilkan pesan kesalahan
            }

            if (snapShot.connectionState == ConnectionState.active) {
              if (snapShot.data == null) {
                return Account2(); // Tampilan jika tidak ada pengguna yang masuk
              } else {
                return Layout(); // Tampilan jika pengguna masuk
              }
            }
            // Tindakan jika ConnectionState bukan ConnectionState.active
            return Scaffold(
              body: Center(
                child:
                    CircularProgressIndicator(), // Menampilkan indikator loading
              ),
            );
          },
        ),
      ),
    );
  }
}
