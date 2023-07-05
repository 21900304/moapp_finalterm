import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shrine/Auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();



  Future<UserCredential?> signInAnonymously() async {
    final UserCredential userCredential = await _auth.signInAnonymously();
    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                ElevatedButton(
                child: const Text('Google Login'),
                onPressed: () async {
                  final User? user = await AuthService().signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/');
                    FirebaseFirestore.instance
                        .collection('USER')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .set(<String, dynamic>{
                      'email': FirebaseAuth.instance.currentUser!.email,
                      'name': FirebaseAuth.instance.currentUser!.displayName,
                      'status_message': "I promise to take the test honestly before GOD",
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                    })
                        .then((value) => print("User added"))
                        .catchError((error) => print("Failed to add user: $error"));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('로그인에 실패했습니다.'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                child: const Text('Guest'),
                onPressed: () async {
                  final UserCredential? userCredential =
                  await signInAnonymously();
                  if (userCredential != null) {
                    // 로그인 성공한 경우 처리할 내용
                    Navigator.pushReplacementNamed(context, '/');
                    FirebaseFirestore.instance
                        .collection('USER')
                        .doc(FirebaseAuth.instance.currentUser!.uid) // uid를 document ID로 사용
                        .set(<String, dynamic>{
                      'status_message': "I promise to take the test honestly before GOD",
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                    })
                        .then((value) => print("User added"))
                        .catchError((error) => print("Failed to add user: $error"));
                  } else {
                    // 로그인 실패한 경우 처리할 내용
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('로그인에 실패했습니다.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
