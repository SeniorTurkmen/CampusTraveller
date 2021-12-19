import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../pages.dart';

class SignUpVm extends ChangeNotifier {
  final BuildContext context;
  late FirebaseAuth fI;

  late FirebaseFirestore fS;
  bool isVisible = true;
  String errorMsg = '';

  late TextEditingController nameController,
      emailController,
      passwordController;
  LoadingProcess status = LoadingProcess.done;
  SignUpVm(this.context) {
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    fI = FirebaseAuth.instance;
    fS = FirebaseFirestore.instance;
  }

  Future<void> signUp() async {
    try {
      errorMsg = '';
      status = LoadingProcess.loading;
      notifyListeners();

      UserCredential _newUser = await fI.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      FirebaseMessaging.instance.getToken();
      log(_newUser.user!.email!);

      fS.collection('users').doc(_newUser.user!.uid).set(UserModel(
              email: _newUser.user!.email!,
              fullName: nameController.text,
              uid: _newUser.user!.uid,
              userType: 'default',
              lastLogin: DateTime.now())
          .toMap);

      await fI.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      status = LoadingProcess.done;
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
        ModalRoute.withName('/'),
      );
    } on FirebaseAuthException catch (e) {
      errorMsg = e.message!;
      status = LoadingProcess.error;
      notifyListeners();
    } catch (e) {
      errorMsg = e.toString();
      status = LoadingProcess.error;
      notifyListeners();
    }
  }

  changeVisiblity() {
    isVisible = !isVisible;
    notifyListeners();
  }
}
