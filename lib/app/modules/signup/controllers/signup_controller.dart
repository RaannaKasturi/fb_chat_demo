import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:fb_chat/app/ui_utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  final signupFormKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool ispasswordObscured = true.obs;

  Future<void> _saveUserData(User user, String email) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final userData = {
      'uid': user.uid,
      'email': email,
      'lastSeen': DateTime.now().toIso8601String(),
    };
    await userDoc.set(userData, SetOptions(merge: true));
  }

  Future<void> signUpUserWithPassword() async {
    if (signupFormKey.currentState?.saveAndValidate() ?? false) {
      final formData = signupFormKey.currentState?.value;
      String email = formData?['Email'];
      String password = formData?['Password'];
      String confirmPassword = formData?['Confirm Password'];
      if (password != confirmPassword) {
        ShowToast.error('Passwords do not match.');
        return;
      }
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await credential.user?.sendEmailVerification();
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
        }
      } catch (e) {
        ShowToast.error(e.toString());
      }
    } else {
      ShowToast.error('Validation failed. Please check your input.');
    }
  }

  Future<void> signUpUserWithGoogle() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithProvider(
        GoogleAuthProvider(),
      );
      await credential.user?.sendEmailVerification();
      if (credential.user != null) {
        await _saveUserData(credential.user!, credential.user!.email ?? '');
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
      }
    } catch (e) {
      ShowToast.error(e.toString());
    }
  }
}
