import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/UserRole.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Observable user state
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isAuthenticated = false.obs;
  RxBool isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAuth();
  }

  /// Initialize service
  Future<AuthService> init() async {
    await _initializeAuth();
    return this;
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      _supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session?.user != null) {
          _handleAuthStateChange(session!.user);
        } else {
          _handleSignOut();
        }
      });

      // Check current session
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        await _handleAuthStateChange(session!.user);
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  /// Handle auth state changes
  Future<void> _handleAuthStateChange(User user) async {
    try {
      // Only load profile if email is confirmed
      if (user.emailConfirmedAt != null) {
        // Fetch user profile from profiles table
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          currentUser.value = UserModel.fromMap(profileData);
          isAuthenticated.value = true;
        } else {
          // Profile doesn't exist, sign out
          await _supabase.auth.signOut();
        }
      } else {
        // Email not confirmed yet
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('Error handling auth state change: $e');
      await _supabase.auth.signOut();
    }
  }

  /// Handle sign out
  void _handleSignOut() {
    currentUser.value = null;
    isAuthenticated.value = false;
  }

  /// Register new user with Supabase Auth
  Future<AuthResult> register({
    required String email,
    required String fullName,
    required String phone,
    required UserRole role,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role.toString().split('.').last,
        },
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          // Email confirmation required
          return AuthResult.success(
            'Registration successful! Please check your email and click the confirmation link to activate your account.',
          );
        } else {
          // Auto-confirmed (shouldn't happen with email confirmation enabled)
          return AuthResult.success('Registration successful!');
        }
      } else {
        return AuthResult.error('Registration failed');
      }
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      print('Registration error: $e');
      return AuthResult.error('Registration failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          return AuthResult.error(
            'Please confirm your email address before logging in. Check your inbox for the confirmation link.',
          );
        }
        return AuthResult.success('Login successful!');
      } else {
        return AuthResult.error('Login failed');
      }
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      print('Login error: $e');
      return AuthResult.error('Login failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      Get.offAllNamed('/');
    } catch (e) {
      print('Sign out error: $e');
      Get.offAllNamed('/');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null && user.emailConfirmedAt != null) {
      try {
        final profileData = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          return UserModel.fromMap(profileData);
        }
      } catch (e) {
        print('Get current user error: $e');
      }
    }
    return null;
  }

  /// Check if session is valid
  Future<bool> validateSession() async {
    try {
      final session = _supabase.auth.currentSession;
      return session?.user?.emailConfirmedAt != null;
    } catch (e) {
      print('Validate session error: $e');
      return false;
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? fullName,
    String? phone,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUser.value == null) {
        return AuthResult.error('User not authenticated');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (additionalData != null) updates.addAll(additionalData);

      if (updates.isEmpty) {
        return AuthResult.success('No changes to update');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUser.value!.id);

      // Refresh current user data
      final updatedData = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.value!.id)
          .single();

      currentUser.value = UserModel.fromMap(updatedData);

      return AuthResult.success('Profile updated successfully');
    } catch (e) {
      print('Update profile error: $e');
      return AuthResult.error('Failed to update profile: ${e.toString()}');
    }
  }

  /// Request password reset
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: '${Get.context!.toString()}/reset-password', // You'll need to set this up
      );

      return AuthResult.success(
        'Password reset email sent. Please check your inbox.',
      );
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      print('Password reset error: $e');
      return AuthResult.error('Failed to send password reset email');
    }
  }

  /// Change password (when user is logged in)
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // First verify current password by re-authenticating
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return AuthResult.error('User not authenticated');
      }

      // Re-authenticate with current password
      final authResponse = await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (authResponse.user == null) {
        return AuthResult.error('Current password is incorrect');
      }

      // Update to new password
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return AuthResult.success('Password updated successfully');
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      print('Change password error: $e');
      return AuthResult.error('Failed to change password');
    }
  }

  /// Resend email confirmation
  Future<AuthResult> resendEmailConfirmation(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      return AuthResult.success(
        'Confirmation email sent. Please check your inbox.',
      );
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      print('Resend confirmation error: $e');
      return AuthResult.error('Failed to resend confirmation email');
    }
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return currentUser.value?.role == role;
  }

  /// Role-based getters
  bool get isAdmin => hasRole(UserRole.admin);
  bool get isAgent => hasRole(UserRole.agent);
  bool get isLandlord => hasRole(UserRole.landlord);
  bool get isTenant => hasRole(UserRole.tenant);
}

/// Auth result wrapper
class AuthResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory AuthResult.success(String message, [dynamic data]) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}