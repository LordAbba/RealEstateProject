import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controllers/RegisterController.dart';


class RegisterPage extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF06B6D4),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left Side - Branding (Desktop only)
              if (Get.width > 768)
                Expanded(
                  flex: 1,
                  child: _buildBrandingSection(),
                ),

              // Right Side - Registration Form
              Expanded(
                flex: Get.width > 768 ? 1 : 1,
                child: Container(
                  margin: EdgeInsets.all(Get.width > 768 ? 32 : 16),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _buildRegistrationForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Container(
      padding: EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('S', style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
                ),
              ),
              SizedBox(width: 16),
              Text('Smart House', style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),

          SizedBox(height: 48),

          // Welcome Message
          Text(
            'Join Smart House',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Create your account and start your journey to finding the perfect home or growing your property business.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          SizedBox(height: 32),

          // Role Benefits
          _buildRoleItem(Icons.person, 'Tenant', 'Find your dream home easily'),
          _buildRoleItem(Icons.business, 'Agent', 'Manage properties professionally'),
          _buildRoleItem(Icons.home, 'Landlord', 'Maximize your property value'),
        ],
      ),
    );
  }

  Widget _buildRoleItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
                Text(description, style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back Button (Mobile only)
          if (Get.width <= 768)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: controller.goBack,
                icon: Icon(Icons.arrow_back),
              ),
            ),

          // Header
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Fill in your details to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 32),

          // Full Name Field
          TextFormField(
            controller: controller.fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // Phone Field
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.trim().length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // Role Selection
          Text('I am a:', style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          )),

          SizedBox(height: 12),

          Obx(() => Row(
            children: controller.roles.asMap().entries.map((entry) {
              final index = entry.key;
              final role = entry.value;
              final label = controller.roleLabels[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectRole(role),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedRole.value == role
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.selectedRole.value == role
                            ? Colors.orange
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: controller.selectedRole.value == role
                            ? Colors.orange
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),

          SizedBox(height: 20),

          // Password Field
          Obx(() => TextFormField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          )),

          SizedBox(height: 20),

          // Confirm Password Field
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: !controller.isConfirmPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != controller.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          )),

          SizedBox(height: 20),

          // Terms and Conditions
          Obx(() => Row(
            children: [
              Checkbox(
                value: controller.agreeToTerms.value,
                onChanged: controller.toggleTermsAgreement,
                activeColor: Colors.orange,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),

          SizedBox(height: 24),

          // Register Button
          Obx(() => SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )),

          SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                )),
              ),
              Expanded(child: Divider()),
            ],
          ),

          SizedBox(height: 24),

          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? ", style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              )),
              GestureDetector(
                onTap: controller.goToLogin,
                child: Text('Sign In', style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}