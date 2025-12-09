import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:get/get.dart';

import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return FormBuilder(
            key: controller.signupFormKey,
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
                  FormBuilderTextField(
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
                  FormBuilderTextField(
                    name: 'Confirm Password',
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
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
                  SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: controller.signUpUserWithPassword,
                    child: const Text("Sign Up"),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Get.offAllNamed(Routes.LOGIN);
                            },
                            child: Text(
                              "Login",
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
          );
        }),
      ),
    );
  }
}
