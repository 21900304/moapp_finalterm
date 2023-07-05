import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shrine/Auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    bool isAnonymous = user?.isAnonymous ?? true;

    return MaterialApp(
      home: Scaffold(
        //backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
            }, icon: const Icon(Icons.arrow_back),),
          actions: <Widget>[
            IconButton(onPressed: (){
              Navigator.pushReplacementNamed(context, '/login');
              AuthService().signOutWithGoogle();
              }, icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
          children: [
            if(isAnonymous)
              Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                  const Text(
                    "<Your PID>",
                    style: TextStyle(
                      fontSize: 40
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "uid: ${user?.uid ?? "Anonymous"}",
                  ),
                  const Text(
                    "email: Anonymous",
                  ),
                  const SizedBox(height: 50),
                  const Text("Jung Hoon Park"),
                  const Text("I promise to take the test honestly before GOD .")
                ],
              )
            else if(user != null && !user.isAnonymous)
              Column(
                children: [
                  Image.network(
                    '${user.photoURL}',
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                  const Text(
                    "<Your PID>",
                    style: TextStyle(
                        fontSize: 40
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "uid: ${user.uid}",
                  ),
                  Text(
                    "email: ${user.email ?? ""}",
                  ),
                  const SizedBox(height: 50),
                  const Text("Jung Hoon Park"),
                  const Text("I promise to take the test honestly before GOD .")
                ],
              )
          ],
        ),
      ),
    );
  }
}
