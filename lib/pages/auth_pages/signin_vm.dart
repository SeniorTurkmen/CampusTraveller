import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../pages.dart';

class SignInVm extends ChangeNotifier {
  final BuildContext context;
  late FirebaseAuth fI;

  late FirebaseFirestore fS;
  bool isVisible = true;
  String errorMsg = '';

  late TextEditingController emailController, passwordController;
  LoadingProcess status = LoadingProcess.done;
  SignInVm(this.context) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    fI = FirebaseAuth.instance;
    fS = FirebaseFirestore.instance;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      status = LoadingProcess.loading;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      if (fI.currentUser != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          ModalRoute.withName('/'),
        );
      }
      status = LoadingProcess.done;
      notifyListeners();
    });
  }

  Future<void> signIn() async {
    try {
      errorMsg = '';
      status = LoadingProcess.loading;
      notifyListeners();

      UserCredential _newUser = await fI.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      FirebaseMessaging.instance.getToken();
      log(_newUser.user!.email!);

      var fireStore =
          await fS.collection('users').doc(_newUser.user!.uid).get();

      Map<String, dynamic> tempData = fireStore.data()!;
      tempData['lastLogin'] = DateTime.now().toIso8601String();

      fS.collection('users').doc(_newUser.user!.uid).update(tempData);

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