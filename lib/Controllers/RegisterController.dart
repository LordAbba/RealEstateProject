import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/UserRole.dart';
import '../Controllers/AuthContoller.dart';

class RegisterController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var selectedRole = 'tenant'.obs;
  var agreeToTerms = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  // Role options
  final List<String> roles = ['tenant', 'agent', 'landlord'];
  final List<String> roleLabels = ['Tenant', 'Agent', 'Landlord'];

  @override
  void onInit() {
    super.onInit();
    // Listen to auth controller loading state
    ever(_authController.isLoading, (loading) => isLoading.value = loading);
  }

  @override
  void onClose() {
    // Dispose controllers
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Select user role
  void selectRole(String role) {
    selectedRole.value = role;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Toggle terms agreement
  void toggleTermsAgreement(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  /// Register user
  Future<void> register() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Check terms agreement
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms & Conditions and Privacy Policy',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate password confirmation
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Password Mismatch',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get selected role enum
    UserRole userRole;
    switch (selectedRole.value) {
      case 'agent':
        userRole = UserRole.agent;
        break;
      case 'landlord':
        userRole = UserRole.landlord;
        break;
      case 'admin':
        userRole = UserRole.admin;
        break;
      default:
        userRole = UserRole.tenant;
    }

    try {
      final success = await _authController.register(
        email: emailController.text.trim(),
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        role: userRole,
        password: passwordController.text,
      );

      if (success) {
        // Registration successful, user will be redirected by AuthController
        _clearForm();
      }
    } catch (e) {
      Get.snackbar(
        'Registration Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Clear form data
  void _clearForm() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = 'tenant';
    agreeToTerms.value = false;
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  /// Navigate to login page
  void goToLogin() {
    Get.offNamed('/login');
  }

  /// Go back (for mobile)
  void goBack() {
    Get.back();
  }

  /// Validate password strength
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Get password strength score (0-4)
  int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) score++;

    return score;
  }

  /// Get password strength label
  String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
      case 5:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  /// Get password strength color
  Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}