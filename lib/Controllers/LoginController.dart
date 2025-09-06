import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/AuthContoller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // FIX: Create unique GlobalKey for each instance
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('LoginController initialized');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    print('LoginController disposed');
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    print('Starting login process...');
    isLoading.value = true;

    try {
      final success = await _authController.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      print('Login result: $success');

      if (success) {
        // Clear form
        emailController.clear();
        passwordController.clear();
        rememberMe.value = false;

        print('Login successful - AuthController will handle navigation');
        // AuthController will handle navigation automatically
      } else {
        print('Login failed - showing error message');
        Get.snackbar(
          'Login Failed',
          'Invalid email or password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed('/register');
  }

  void goToForgotPassword() {
    _showForgotPasswordDialog();
  }

  void goBack() {
    Get.back();
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive a password reset link.'),
            SizedBox(height: 16),
            TextFormField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              resetEmailController.dispose();
              Get.back();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty && GetUtils.isEmail(email)) {
                Get.back();

                try {
                  await _authController.resetPassword(email);
                  Get.snackbar(
                    'Reset Link Sent',
                    'Check your email for password reset instructions',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to send reset link. Please try again.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              } else {
                Get.snackbar(
                  'Invalid Email',
                  'Please enter a valid email address',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
              resetEmailController.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}