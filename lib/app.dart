// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/add.dart';
import 'package:shrine/profile.dart';
import 'package:shrine/wish.dart';

import 'more.dart';
import 'home.dart';
import 'login.dart';

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => MyAppState(),
    child: MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/': (BuildContext context) => HomePage(),
        '/profile': (BuildContext context) => const ProfilePage(),
        '/add': (BuildContext context) => AddProduct(),
        '/wish': (BuildContext context) => WishPage(),


      },
      theme: ThemeData.light(useMaterial3: true),
    ));
  }
}

class MyAppState extends ChangeNotifier {

  var wishs = [];
  var prices = [];
  var descriptions = [];
  var imageURLs = [];
  var ids = [];//예비 쓸지 모름
  int favoriteCount = 41;

  var wishids = [];

  void toggleWish( String name, String price, String description, String imageURL, String id) {
    if (wishs.contains(name)) {
      wishs.remove(name);
      prices.remove(price);
      descriptions.remove(description);
      imageURLs.remove(imageURL);
      ids.remove(id);
      //FirebaseFirestore.instance.collection('WiSH').doc(id).delete();
    } else {
      wishs.add(name);
      prices.add(price);
      descriptions.add(description);
      imageURLs.add(imageURL);
      ids.add(id);
      FirebaseFirestore.instance.collection('WiSH').doc(name)
          .set(<String, dynamic>{
        'name': name,
        'price': price,
        'user': FirebaseAuth.instance.currentUser!.displayName,
      });
      wishids.add(FirebaseAuth.instance.currentUser!.uid);
    }
    notifyListeners();
  }

  void toggleFavorite() {
    notifyListeners();
  }

  void incNum(){
    favoriteCount++;
    notifyListeners();
  }
  void decNum(){
    favoriteCount--;
    notifyListeners();
  }

}
