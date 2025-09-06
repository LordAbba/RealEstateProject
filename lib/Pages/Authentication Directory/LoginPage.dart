import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/LoginController.dart';

class LoginPage extends StatelessWidget {
  // FIX: Use Get.lazyPut to avoid multiple instances
  LoginPage() {
    Get.lazyPut(() => LoginController());
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Get the controller instance without creating a new one
    final LoginController controller = Get.find<LoginController>();

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: _buildResponsiveLayout(controller),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(LoginController controller) {
    return Row(
      children: [
        // Left Side - Branding (Desktop only)
        if (Get.width > 768)
          Expanded(
            flex: 1,
            child: _buildBrandingSection(),
          ),

        // Right Side - Login Form
        Expanded(
          flex: Get.width > 768 ? 1 : 1,
          child: Container(
            margin: EdgeInsets.all(Get.width > 768 ? 32 : 16),
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
            child: _buildLoginForm(controller),
          ),
        ),
      ],
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
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Access your personalized dashboard and continue your property search journey.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          SizedBox(height: 32),

          // Features List
          _buildFeatureItem(Icons.security, 'Secure & Verified Platform'),
          _buildFeatureItem(Icons.search, 'Advanced Property Search'),
          _buildFeatureItem(Icons.people, 'Connect with Trusted Agents'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
          Text(text, style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          )),
        ],
      ),
    );
  }

  Widget _buildLoginForm(LoginController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
            'Sign In',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Enter your credentials to access your account',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: 32),

          // Email Field
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 20),

          // Password Field
          Obx(() => TextFormField(
            controller: controller.passwordController,
            obscureText: !controller.isPasswordVisible.value,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange, width: 2),
              ),
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
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          )),

          SizedBox(height: 16),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: controller.toggleRememberMe,
                    activeColor: Colors.orange,
                  ),
                  Text('Remember me', style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  )),
                ],
              )),
              TextButton(
                onPressed: controller.goToForgotPassword,
                child: Text('Forgot Password?', style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                )),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Login Button
          Obx(() => SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
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
                'Sign In',
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

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              )),
              GestureDetector(
                onTap: controller.goToRegister,
                child: Text('Sign Up', style: TextStyle(
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