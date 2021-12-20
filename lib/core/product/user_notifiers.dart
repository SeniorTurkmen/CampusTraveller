import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../models/user_model.dart';

class UserNotifier extends ChangeNotifier {
  UserModel? currentUser;
  UserNotifier();

  setCurrentUser(UserModel user) {
    currentUser = user;
    log('setted');
  }
}

extension data on UserModel {
  bool get isAdmin {
    debugPrint(email);
    return userType == 'admin';
  }
}
