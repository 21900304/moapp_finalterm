// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:shrine/uesrinfo.dart';
import 'firebase_options.dart';


class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  bool _emailVerified = false;
  bool get emailVerified => _emailVerified;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<UserAddInfo> _useraddinfo = [];
  List<UserAddInfo> get useraddinfo => _useraddinfo;


  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);


    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _emailVerified = user.emailVerified;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _useraddinfo = [];
          for (final document in snapshot.docs) {
            _useraddinfo.add(
              UserAddInfo(
                email: document.data()['email'] as String,
                name: document.data()['name'] as String,
                status_message: document.data()['status_message'] as String,
                uid: document.data()['uid'] as String,
              ),
            );
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _emailVerified = false;
        _useraddinfo = [];
        _guestBookSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> refreshLoggedInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await currentUser.reload();
  }

  Future<String> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('USER')
        .add(<String, dynamic>{
      'email': FirebaseAuth.instance.currentUser!.email,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'status_massage': message,
      'uid': FirebaseAuth.instance.currentUser!.uid,
    }).then((messageRef) {
      String docId = messageRef.id;
      return docId;
    });
  }
}
