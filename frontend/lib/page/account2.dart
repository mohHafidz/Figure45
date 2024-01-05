import 'package:flutter/material.dart';
import 'package:frontend/page/signIn.dart';
import 'package:frontend/page/signUp.dart';

void main() => runApp(const Account2());

class Account2 extends StatefulWidget {
  const Account2({Key? key}) : super(key: key);

  @override
  _Account2State createState() => _Account2State();
}

class _Account2State extends State<Account2> {
  final PageController _pageController = PageController(initialPage: 0);
  bool signIn = true;
  bool signUp = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          // const Spacer(),
                          Text(
                            'Welcome',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // const SizedBox(width: 40),
                        ],
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1,
                        indent: 30,
                        endIndent: 30,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.jumpToPage(0);
                                  setState(() {
                                    signIn = true;
                                    signUp = false;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    'SIGN IN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: signIn
                                          ? Colors.black
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0,
                                ),
                              ),
                            ),
                            Container(
                              height: 45,
                              child: VerticalDivider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.jumpToPage(1);
                                  setState(() {
                                    signIn = false;
                                    signUp = true;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    'SIGN UP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: signUp
                                          ? Colors.black
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    height: 750,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          if (page == 0) {
                            signIn = true;
                            signUp = false;
                          } else {
                            signIn = false;
                            signUp = true;
                          }
                        });
                      },
                      children: const [
                        Login(),
                        SignUp(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
