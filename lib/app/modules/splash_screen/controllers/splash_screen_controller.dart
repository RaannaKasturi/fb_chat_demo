import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  SplashScreenController() {
    print('[DBG] SplashScreenController.constructor');
  }

  @override
  void onInit() {
    super.onInit();
    print('[DBG] SplashScreenController.onInit');
  }

  @override
  void onReady() {
    super.onReady();
    print('[DBG] SplashScreenController.onReady');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
  }
}
