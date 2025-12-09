import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowToast {
  ShowToast._();

  static void success(
    String message, {
    ToastGravity gravity = ToastGravity.CENTER,
  }) {
    Fluttertoast.showToast(
      msg: message,
      fontSize: 14,
      timeInSecForIosWeb: 2,
      gravity: gravity,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void info(
    String message, {
    ToastGravity gravity = ToastGravity.CENTER,
  }) {
    Fluttertoast.showToast(
      msg: message,
      fontSize: 14,
      timeInSecForIosWeb: 2,
      gravity: gravity,
      toastLength: message.length <= 20
          ? Toast.LENGTH_SHORT
          : Toast.LENGTH_LONG,
      backgroundColor: Colors.grey.shade200,
      textColor: Colors.black,
    );
  }

  static void error(
    String message, {
    ToastGravity gravity = ToastGravity.CENTER,
  }) {
    Fluttertoast.showToast(
      msg: message,
      fontSize: 14,
      timeInSecForIosWeb: 2,
      gravity: gravity,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.red.shade100,
      textColor: Colors.red,
    );
  }
}
