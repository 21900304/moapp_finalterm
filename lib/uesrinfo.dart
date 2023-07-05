// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';

class UserAddInfo{
  UserAddInfo({ required this.email, required this.name, required this.status_message, required this.uid});
  final String email;
  final String name;
  final String status_message;
  final String uid;
}
