import 'package:fb_chat/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:fb_chat/app/theme/theme.dart';
import 'package:fb_chat/app/theme/util.dart';
import 'package:fb_chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FBChatApp());
}

class FBChatApp extends StatelessWidget {
  const FBChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Poppins", "Syne");
    MaterialTheme theme = MaterialTheme(textTheme);
    return GetMaterialApp(
      themeMode: ThemeMode.light,
      theme: theme
          .light(), // brightness == Brightness.light ? theme.light() : theme.dark(),
      title: "Firebase Chat",
      initialBinding: SplashScreenBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
