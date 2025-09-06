/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Controllers/AuthContoller.dart';

class OTPVerificationPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  // Local controllers for OTP input
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    // Get verification type from route arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final verificationType = args['type'] ?? 'register';

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

              // Right Side - OTP Form
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
                      child: _buildOTPForm(verificationType),
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
            'Almost There!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'We\'ve sent a verification code to your email address. Enter the code below to complete your registration.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          SizedBox(height: 32),

          // Security Features
          _buildSecurityItem(Icons.security, 'Secure Verification', 'Your account security is our priority'),
          _buildSecurityItem(Icons.timer, 'Time Limited', 'Code expires in 5 minutes'),
          _buildSecurityItem(Icons.email, 'Email Protected', 'Verification sent to your registered email'),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, String description) {
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

  Widget _buildOTPForm(String verificationType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back Button (Mobile only)
        if (Get.width <= 768)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back),
            ),
          ),

        // Header
        Text(
          verificationType == 'register' ? 'Verify Your Email' : 'Re-authenticate',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),

        SizedBox(height: 8),

        Obx(() => RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            children: [
              TextSpan(text: 'We\'ve sent a 6-digit verification code to\n'),
              TextSpan(
                text: authController.otpEmail.value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        )),

        SizedBox(height: 32),

        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),

        SizedBox(height: 24),

        // Resend Button with Cooldown
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Didn\'t receive the code?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            GestureDetector(
              onTap: authController.resendCooldown.value == 0 && !authController.isLoading.value
                  ? authController.resendOTP
                  : null,
              child: Text(
                authController.resendCooldown.value > 0
                    ? 'Resend in ${authController.resendCooldown.value}s'
                    : authController.isLoading.value
                    ? 'Sending...'
                    : 'Resend Code',
                style: TextStyle(
                  fontSize: 14,
                  color: authController.resendCooldown.value == 0 && !authController.isLoading.value
                      ? Colors.orange
                      : Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        )),

        SizedBox(height: 32),

        // Verify Button
        Obx(() => SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: authController.isLoading.value ? null : () => _verifyOTP(verificationType),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: authController.isLoading.value
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              verificationType == 'register' ? 'Verify & Create Account' : 'Verify Identity',
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

        // Go Back Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Want to use different email? ", style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            )),
            GestureDetector(
              onTap: () => Get.back(),
              child: Text('Go Back', style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Help Text
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check your spam folder if you don\'t see the email. The code is valid for 5 minutes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          _onOTPChanged(value, index);
        },
        onTap: () {
          // Clear field when tapped
          otpControllers[index].clear();
        },
      ),
    );
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last field, remove focus
        focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      // Handle backspace - move to previous field
      focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOTP(String verificationType) async {
    final otp = _otpCode;

    if (otp.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter all 6 digits',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authController.verifyOTP(otp, verificationType);

    if (!success) {
      // Clear OTP fields on failure
      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    }
    // On success, the AuthController handles navigation automatically
  }
}*/