import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:fb_chat/app/ui_utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var ispasswordObscured = true.obs;
  final loginFormKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveUserData(User user, String email) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final userData = {
      'uid': user.uid,
      'email': email,
      'lastSeen': DateTime.now().toIso8601String(),
    };
    await userDoc.set(userData, SetOptions(merge: true));
  }

  Future<void> signInUserWithPassword() async {
    if (loginFormKey.currentState?.saveAndValidate() ?? false) {
      final email = loginFormKey.currentState?.fields['Email']?.value;
      final password = loginFormKey.currentState?.fields['Password']?.value;
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (credential.user != null) {
          await _saveUserData(credential.user!, email);
        }
        ShowToast.success('Signup successful! Please verify your email.');
        Get.offAllNamed(Routes.HOME);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ShowToast.error('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          ShowToast.error(
            'The account already exists for that email. Please login.',
          );
        } else if (e.code == 'user-not-found') {
          ShowToast.error('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          ShowToast.error('Wrong password provided for that user.');
        } else {
          ShowToast.error(e.message ?? 'Authentication failed.');
        }
      } catch (e) {
        ShowToast.error(e.toString());
      }
    } else {
      ShowToast.error('Validation failed. Please check your input.');
    }
  }

  Future<void> signInUserWithGoogle() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithProvider(
        GoogleAuthProvider(),
      );
      if (credential.user != null) {
        await _saveUserData(credential.user!, credential.user!.email ?? '');
      }
      await credential.user?.sendEmailVerification();
      ShowToast.success('Signup successful! Please verify your email.');
      Get.offAllNamed(Routes.HOME);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ShowToast.error('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ShowToast.error(
          'The account already exists for that email. Please login.',
        );
      }
    } catch (e) {
      ShowToast.error(e.toString());
    }
  }
}
