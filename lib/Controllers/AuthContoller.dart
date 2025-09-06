import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/UserRole.dart';
import '../Services/SupaBaseService.dart';

class AuthController extends GetxController {
  // Get the SupabaseService instance
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable variables
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    // Listen to auth state changes
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('Auth State Change: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session?.user != null) {
            print('User signed in: ${session!.user.email}');
            _getCurrentUserData();
          }
          break;
        case AuthChangeEvent.signedOut:
          print('User signed out');
          _handleSignOut();
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            print('User updated');
            _getCurrentUserData();
          }
          break;
        default:
          break;
      }
    });

    // Check if user is already signed in
    final currentSession = _supabaseService.client.auth.currentSession;
    if (currentSession?.user != null) {
      print('Found existing session for: ${currentSession!.user.email}');
      _getCurrentUserData();
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String fullName,
    required String phone,
    required UserRole role,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Sign up with Supabase Auth - INCLUDING the data parameter
      final AuthResponse response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role.toString().split('.').last,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Check if there's an error
      if (response.user?.emailConfirmedAt == null) {
        // Email confirmation required
        Get.snackbar(
          'Check Your Email',
          'Please check your email and click the confirmation link to activate your account.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return true;
      }

      // If email is confirmed immediately, get user data
      await _getCurrentUserData();

      Get.snackbar(
        'Success',
        'Account created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;

    } on AuthException catch (e) {
      String errorMessage = 'Registration failed';

      // Handle specific Supabase auth errors
      if (e.message.toLowerCase().contains('user already registered') ||
          e.message.toLowerCase().contains('already registered')) {
        errorMessage = 'An account with this email already exists';
      } else if (e.message.toLowerCase().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address';
      } else if (e.message.toLowerCase().contains('password')) {
        errorMessage = 'Password must be at least 6 characters long';
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        'Registration Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Auth Error: ${e.message}');
      return false;

    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Registration Error: $e');
      return false;

    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final AuthResponse response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: Invalid credentials');
      }

      print('Login successful for: ${response.user!.email}');

      // The auth state change listener will call _getCurrentUserData() automatically
      return true;

    } on AuthException catch (e) {
      String errorMessage = 'Login failed';

      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid email or password')) {
        errorMessage = 'Invalid email or password';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Please confirm your email address first';
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        'Login Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Login Error: ${e.message}');
      return false;

    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Login Error: $e');
      return false;

    } finally {
      isLoading.value = false;
    }
  }

  /// Get current user data - FIXED with better error handling
  Future<void> _getCurrentUserData() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        print('No authenticated user found');
        return;
      }

      print('Getting user data for: ${user.email}');

      // Fetch user profile from profiles table with better error handling
      try {
        final userModel = await _supabaseService.getUserById(user.id);

        if (userModel != null) {
          currentUser.value = userModel;
          isAuthenticated.value = true;

          // Extract role string
          String roleString;
          if (userModel.role is UserRole) {
            roleString = userModel.role.toString().split('.').last;
          } else {
            roleString = userModel.role.toString();
          }

          print('User authenticated with role: $roleString');

          // Show welcome message
          Get.snackbar(
            'Welcome Back',
            'Login successful!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );

          // Add delay to ensure snackbar shows and database operations complete
          await Future.delayed(Duration(milliseconds: 1000));

          // Navigate based on user role
          _navigateBasedOnRole(roleString);
        } else {
          print('User profile not found in database');
          // Don't sign out immediately - maybe profile is still being created
          await Future.delayed(Duration(seconds: 2));

          // Try once more
          final retryUserModel = await _supabaseService.getUserById(user.id);
          if (retryUserModel == null) {
            print('Profile still not found after retry, signing out');
            await signOut();
          }
        }
      } catch (profileError) {
        print('Error fetching user profile: $profileError');

        // CRITICAL: Don't sign out immediately on profile fetch error
        // The database policy issue might resolve itself
        Get.snackbar(
          'Profile Loading Issue',
          'Having trouble loading your profile. Please try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Try to recover by checking if it's a temporary database issue
        await Future.delayed(Duration(seconds: 2));

        // Attempt recovery - try once more
        try {
          final retryUserModel = await _supabaseService.getUserById(user.id);
          if (retryUserModel != null) {
            currentUser.value = retryUserModel;
            isAuthenticated.value = true;
            String roleString = retryUserModel.role.toString().split('.').last;
            _navigateBasedOnRole(roleString);
            return;
          }
        } catch (retryError) {
          print('Retry failed: $retryError');
        }

        // If all else fails, sign out
        await signOut();
      }
    } catch (e) {
      print('Critical error in _getCurrentUserData: $e');
      await signOut();
    }
  }

  /// Navigate user based on their role
  void _navigateBasedOnRole(String role) {
    print('Navigating user with role: $role');

    // Use offAllNamed to clear all previous routes and prevent back navigation
    switch (role.toLowerCase()) {
      case 'tenant':
        print('Navigating to tenant dashboard');
        Get.offAllNamed('/tenant/dashboard');
        break;
      case 'agent':
        print('Navigating to agent dashboard');
        Get.offAllNamed('/agent/dashboard');
        break;
      case 'landlord':
        print('Navigating to landlord dashboard');
        Get.offAllNamed('/landlord/dashboard');
        break;
      case 'admin':
        print('Navigating to admin dashboard');
        Get.offAllNamed('/admin/dashboard');
        break;
      default:
        print('Unknown role: $role, defaulting to tenant dashboard');
        Get.offAllNamed('/tenant/dashboard');
    }
  }

  /// Public method for getting current user (used by middleware)
  Future<void> getCurrentUser() async {
    await _getCurrentUserData();
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      print('Signing out user...');
      await _supabaseService.client.auth.signOut();
      _handleSignOut();
    } catch (e) {
      print('Sign out error: $e');
      _handleSignOut(); // Force local sign out
    }
  }

  /// Handle sign out cleanup
  void _handleSignOut() {
    print('Handling sign out cleanup...');
    currentUser.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed('/login');
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;

      await _supabaseService.client.auth.resetPasswordForEmail(email);

      Get.snackbar(
        'Reset Email Sent',
        'Please check your email for password reset instructions.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      return true;

    } on AuthException catch (e) {
      Get.snackbar(
        'Reset Password Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Reset password error: ${e.message}');
      return false;

    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Reset password error: $e');
      return false;

    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    if (currentUser.value == null) return false;

    try {
      isLoading.value = true;

      final updatedUser = await _supabaseService.updateUserProfile(
        userId: currentUser.value!.id,
        fullName: fullName,
        phone: phone,
      );

      if (updatedUser != null) {
        currentUser.value = updatedUser;

        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      }

      return false;

    } catch (e) {
      Get.snackbar(
        'Update Error',
        'Failed to update profile. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Update profile error: $e');
      return false;

    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current user has specific role
  bool hasRole(String role) {
    return currentUser.value?.role.toString().split('.').last == role;
  }

  /// Check if user is admin
  bool get isAdmin => hasRole('admin');

  /// Check if user is agent
  bool get isAgent => hasRole('agent');

  /// Check if user is landlord
  bool get isLandlord => hasRole('landlord');

  /// Check if user is tenant
  bool get isTenant => hasRole('tenant');
}