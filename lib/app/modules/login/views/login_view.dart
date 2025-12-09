import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FormBuilder(
          key: controller.loginFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Text(
                  "FB Chat Signup",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: 'Email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                Obx(
                  () => FormBuilderTextField(
                    name: 'Password',
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.ispasswordObscured.value =
                              !controller.ispasswordObscured.value;
                        },
                        icon: Icon(
                          controller.ispasswordObscured.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: controller.ispasswordObscured.value,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.password(),
                      FormBuilderValidators.minLength(8),
                      FormBuilderValidators.maxLength(20),
                      FormBuilderValidators.hasLowercaseChars(),
                      FormBuilderValidators.hasUppercaseChars(),
                      FormBuilderValidators.hasSpecialChars(),
                      FormBuilderValidators.hasNumericChars(),
                    ]),
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.signInUserWithPassword,
                  child: const Text("Login"),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Get.offAllNamed(Routes.SIGNUP);
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
