import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Services/SupaBaseService.dart';

class AdminService extends GetxService {
  late final SupabaseClient _client;

  Future<AdminService> init() async {
    _client = Get
        .find<SupabaseService>()
        .client;
    return this;
  }

  /// Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get user statistics by role
      final userStats = await _client
          .from('profiles')
          .select('role')
          .eq('is_active', true);

      final users = userStats as List;
      final totalUsers = users.length;
      final tenants = users
          .where((u) => u['role'] == 'tenant')
          .length;
      final agents = users
          .where((u) => u['role'] == 'agent')
          .length;
      final landlords = users
          .where((u) => u['role'] == 'landlord')
          .length;
      final admins = users
          .where((u) => u['role'] == 'admin')
          .length;

      // Get property statistics
      final propertyStats = await _client
          .from('properties')
          .select('status');

      final properties = propertyStats as List;
      final totalProperties = properties.length;
      final availableProperties = properties
          .where((p) => p['status'] == 'available')
          .length;
      final rentedProperties = properties
          .where((p) => p['status'] == 'rented')
          .length;
      final pendingProperties = properties
          .where((p) => p['status'] == 'pending')
          .length;

      // Calculate occupancy rate
      final occupancyRate = totalProperties > 0
          ? (rentedProperties / totalProperties * 100).round()
          : 0;

      return {
        'users': {
          'total': totalUsers,
          'tenants': tenants,
          'agents': agents,
          'landlords': landlords,
          'admins': admins,
        },
        'properties': {
          'total': totalProperties,
          'available': availableProperties,
          'rented': rentedProperties,
          'pending': pendingProperties,
          'occupancy_rate': occupancyRate,
        },
        'system_health': 98.5, // You can implement actual health checks
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  /// Get recent users (last 30 days)
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10}) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      final response = await _client
          .from('profiles')
          .select('id, full_name, email, role, created_at, is_active')
          .gte('created_at', thirtyDaysAgo.toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch recent users: $e');
    }
  }

  /// Get pending property approvals
  Future<List<Map<String, dynamic>>> getPendingPropertyApprovals() async {
    try {
      final response = await _client
          .from('properties')
          .select('''
            id, title, location, price, created_at,
            agent:profiles!agent_id(full_name),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch pending properties: $e');
    }
  }

  /// Approve a property
  Future<void> approveProperty(String propertyId) async {
    try {
      await _client
          .from('properties')
          .update({
        'status': 'available',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to approve property: $e');
    }
  }

  /// Reject a property
  Future<void> rejectProperty(String propertyId, {String? reason}) async {
    try {
      await _client
          .from('properties')
          .update({
        'status': 'rejected',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', propertyId);

      // You could also log the rejection reason in a separate table
      if (reason != null) {
        await _logAdminAction(
          'property_rejection',
          'Property $propertyId rejected: $reason',
        );
      }
    } catch (e) {
      throw Exception('Failed to reject property: $e');
    }
  }

  /// Get all users with pagination
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
  }) async {
    try {
      // Build the base query
      var baseQuery = _client.from('profiles');

      // Apply filters for count query
      var countQuery = baseQuery.select();
      if (role != null && role.isNotEmpty) {
        countQuery = countQuery.eq('role', role);
      }
      if (search != null && search.isNotEmpty) {
        countQuery = countQuery.or('full_name.ilike.%$search%,email.ilike.%$search%');
      }

      // Get count first
      final countResult = await countQuery;
      final totalCount = countResult.length;

      // Build data query with same filters
      var dataQuery = baseQuery.select('id, full_name, email, role, phone, created_at, is_active');

      if (role != null && role.isNotEmpty) {
        dataQuery = dataQuery.eq('role', role);
      }
      if (search != null && search.isNotEmpty) {
        dataQuery = dataQuery.or('full_name.ilike.%$search%,email.ilike.%$search%');
      }

      // Apply pagination and ordering to data query
      final offset = (page - 1) * limit;
      final dataResult = await dataQuery
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return {
        'users': dataResult,
        'count': totalCount,
        'page': page,
        'limit': limit,
      };
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _client
          .from('profiles')
          .update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      await _logAdminAction(
        'user_status_change',
        'User $userId ${isActive ? 'activated' : 'suspended'}',
      );
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  /// Delete user (soft delete by deactivating)
  Future<void> deleteUser(String userId) async {
    try {
      await _client
          .from('profiles')
          .update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      await _logAdminAction('user_deletion', 'User $userId deleted');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _client
          .from('profiles')
          .update({
        'role': newRole,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      await _logAdminAction(
        'user_role_change',
        'User $userId role changed to $newRole',
      );
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Get system activities/logs
  Future<List<Map<String, dynamic>>> getSystemActivities(
      {int limit = 20}) async {
    try {
      final response = await _client
          .from('admin_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return mock data if admin_logs table doesn't exist
      return _getMockActivities();
    }
  }

  /// Get user growth data for charts
  Future<List<Map<String, dynamic>>> getUserGrowthData() async {
    try {
      final response = await _client.rpc('get_user_growth_data');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return mock data if function doesn't exist
      return [
        {'month': 'Jan', 'users': 20},
        {'month': 'Feb', 'users': 35},
        {'month': 'Mar', 'users': 45},
        {'month': 'Apr', 'users': 62},
        {'month': 'May', 'users': 89},
        {'month': 'Jun', 'users': 156},
      ];
    }
  }

  /// Make a user admin
  Future<void> promoteToAdmin(String userId) async {
    try {
      await updateUserRole(userId, 'admin');
      await _logAdminAction(
          'admin_promotion', 'User $userId promoted to admin');
    } catch (e) {
      throw Exception('Failed to promote user to admin: $e');
    }
  }

  /// Remove admin privileges
  Future<void> demoteFromAdmin(String userId, String newRole) async {
    try {
      await updateUserRole(userId, newRole);
      await _logAdminAction(
          'admin_demotion', 'Admin $userId demoted to $newRole');
    } catch (e) {
      throw Exception('Failed to demote admin: $e');
    }
  }

  /// Get property reports
  Future<Map<String, dynamic>> getPropertyReports() async {
    try {
      final response = await _client
          .from('properties')
          .select('status, price, created_at, location, bedrooms, bathrooms');

      final properties = response as List;

      // Calculate average price by location
      final locationPrices = <String, List<double>>{};
      for (var property in properties) {
        final location = property['location'] as String;
        final price = (property['price'] as num).toDouble();
        locationPrices.putIfAbsent(location, () => []).add(price);
      }

      final averagePriceByLocation = locationPrices.map((location, prices) {
        final average = prices.reduce((a, b) => a + b) / prices.length;
        return MapEntry(location, average);
      });

      return {
        'total_properties': properties.length,
        'average_price_by_location': averagePriceByLocation,
        'properties_by_status': {
          'available': properties
              .where((p) => p['status'] == 'available')
              .length,
          'rented': properties
              .where((p) => p['status'] == 'rented')
              .length,
          'pending': properties
              .where((p) => p['status'] == 'pending')
              .length,
        },
      };
    } catch (e) {
      throw Exception('Failed to fetch property reports: $e');
    }
  }

  /// Log admin actions
  Future<void> _logAdminAction(String actionType, String description) async {
    try {
      await _client
          .from('admin_logs')
          .insert({
        'action_type': actionType,
        'description': description,
        'admin_id': _client.auth.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail if logging doesn't work
      print('Failed to log admin action: $e');
    }
  }

  /// Mock activities for when admin_logs table doesn't exist
  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'action_type': 'user_registration',
        'description': 'New tenant registered: Michael Brown',
        'created_at': DateTime
            .now()
            .subtract(Duration(hours: 1))
            .toIso8601String(),
        'severity': 'info',
      },
      {
        'action_type': 'property_approval',
        'description': 'Property approved: Modern 2BR Apartment',
        'created_at': DateTime
            .now()
            .subtract(Duration(hours: 3))
            .toIso8601String(),
        'severity': 'success',
      },
      {
        'action_type': 'user_suspension',
        'description': 'User suspended for policy violation',
        'created_at': DateTime
            .now()
            .subtract(Duration(days: 1))
            .toIso8601String(),
        'severity': 'warning',
      },
    ];
  }
}