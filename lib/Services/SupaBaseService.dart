import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../Models/UserRole.dart';

class SupabaseService extends GetxService {
  late SupabaseClient _client;

  // Configuration - Replace with your actual Supabase credentials
  static const String _supabaseUrl = 'https://uqbprzhrppibqxbldgux.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxYnByemhycHBpYnF4YmxkZ3V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzMTAzNTMsImV4cCI6MjA3MTg4NjM1M30.1MAcFYjo9Lm9Szxwei7Awk_jDDDL9h5BkGlprOR1iWk';

  Future<SupabaseService> init() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );

      _client = Supabase.instance.client;
      print('Supabase initialized successfully');
      return this;
    } catch (e) {
      print('Supabase initialization error: $e');
      rethrow;
    }
  }

  SupabaseClient get client => _client;

  // ========== PROFILE OPERATIONS ==========

  /// Get user profile by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      print('Get user by ID error: $e');
      return null;
    }
  }

  /// Get user profile by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      print('Get user by email error: $e');
      return null;
    }
  }

  /// Update user profile
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (profileImage != null) updateData['profile_image'] = profileImage;

      if (updateData.isEmpty) return null;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromMap(response);
    } catch (e) {
      print('Update user profile error: $e');
      return null;
    }
  }

  /// Get all users (Admin only)
  Future<List<UserModel>> getAllUsers({
    String? role,
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from('profiles').select();

      if (role != null) query = query.eq('role', role);
      if (isActive != null) query = query.eq('is_active', isActive);

      query = query.order('created_at', ascending: false);

      if (limit != null && offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => UserModel.fromMap(json))
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  /// Update user status (Admin only)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _client
          .from('profiles')
          .update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Update user status error: $e');
      return false;
    }
  }

  // ========== PROPERTY OPERATIONS ==========

  /// Create new property
  Future<PropertyModel?> createProperty({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required List<String> amenities,
    required List<String> images,
    required String agentId,
    String? landlordId,
  }) async {
    try {
      final response = await _client.from('properties').insert({
        'title': title,
        'description': description,
        'price': price,
        'location': location,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'amenities': amenities,
        'images': images,
        'agent_id': agentId,
        'landlord_id': landlordId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return PropertyModel.fromMap(response);
    } catch (e) {
      print('Create property error: $e');
      return null;
    }
  }

  /// Get all properties
  Future<List<PropertyModel>> getProperties({
    String? status,
    String? agentId,
    String? landlordId,
    double? minPrice,
    double? maxPrice,
    String? location,
    int? bedrooms,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from('properties').select('''
      *,
      agent:agent_id(id, full_name, email, phone),
      landlord:landlord_id(id, full_name, email, phone)
    ''');

      // Apply filters
      if (status != null) query = query.eq('status', status);
      if (agentId != null) query = query.eq('agent_id', agentId);
      if (landlordId != null) query = query.eq('landlord_id', landlordId);
      if (minPrice != null) query = query.gte('price', minPrice);
      if (maxPrice != null) query = query.lte('price', maxPrice);
      if (location != null) query = query.ilike('location', '%$location%');
      if (bedrooms != null) query = query.eq('bedrooms', bedrooms);

      // Apply ordering
      query = query.order('created_at', ascending: false);

      // Apply pagination
      if (limit != null && offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => PropertyModel.fromMap(json))
          .toList();
    } catch (e) {
      print('Get properties error: $e');
      return [];
    }
  }

  /// Get property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      final response = await _client
          .from('properties')
          .select('''
            *,
            agent:agent_id(id, full_name, email, phone),
            landlord:landlord_id(id, full_name, email, phone)
          ''')
          .eq('id', propertyId)
          .maybeSingle();

      if (response == null) return null;

      return PropertyModel.fromMap(response);
    } catch (e) {
      print('Get property by ID error: $e');
      return null;
    }
  }

  /// Update property
  Future<PropertyModel?> updateProperty({
    required String propertyId,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    List<String>? images,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (location != null) updateData['location'] = location;
      if (bedrooms != null) updateData['bedrooms'] = bedrooms;
      if (bathrooms != null) updateData['bathrooms'] = bathrooms;
      if (amenities != null) updateData['amenities'] = amenities;
      if (images != null) updateData['images'] = images;
      if (status != null) updateData['status'] = status;

      if (updateData.isEmpty) return null;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('properties')
          .update(updateData)
          .eq('id', propertyId)
          .select('''
            *,
            agent:agent_id(id, full_name, email, phone),
            landlord:landlord_id(id, full_name, email, phone)
          ''')
          .maybeSingle();

      if (response == null) return null;

      return PropertyModel.fromMap(response);
    } catch (e) {
      print('Update property error: $e');
      return null;
    }
  }

  /// Delete property
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _client.from('properties').delete().eq('id', propertyId);
      return true;
    } catch (e) {
      print('Delete property error: $e');
      return false;
    }
  }

  /// Search properties
  Future<List<PropertyModel>> searchProperties({
    String? keyword,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from('properties').select('''
      *,
      agent:agent_id(id, full_name, email, phone)
    ''').eq('status', 'available');

      // Apply filters
      if (keyword != null) {
        query = query.or('title.ilike.%$keyword%,description.ilike.%$keyword%');
      }
      if (location != null) {
        query = query.ilike('location', '%$location%');
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (bedrooms != null) {
        query = query.eq('bedrooms', bedrooms);
      }
      if (bathrooms != null) {
        query = query.eq('bathrooms', bathrooms);
      }

      // Handle amenities filter
      if (amenities != null && amenities.isNotEmpty) {
        for (String amenity in amenities) {
          query = query.contains('amenities', [amenity]);
        }
      }

      // Apply ordering
      query = query.order('created_at', ascending: false);

      // Apply pagination
      if (limit != null && offset != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => PropertyModel.fromMap(json))
          .toList();
    } catch (e) {
      print('Search properties error: $e');
      return [];
    }
  }

  // ========== FAVORITES OPERATIONS ==========

  /// Add property to favorites
  Future<bool> addToFavorites(String userId, String propertyId) async {
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'property_id': propertyId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Add to favorites error: $e');
      return false;
    }
  }

  /// Remove property from favorites
  Future<bool> removeFromFavorites(String userId, String propertyId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('property_id', propertyId);

      return true;
    } catch (e) {
      print('Remove from favorites error: $e');
      return false;
    }
  }

  /// Get user's favorite properties
  Future<List<PropertyModel>> getFavoriteProperties(String userId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('''
            property:property_id(
              *,
              agent:agent_id(id, full_name, email, phone)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => PropertyModel.fromMap(item['property']))
          .toList();
    } catch (e) {
      print('Get favorite properties error: $e');
      return [];
    }
  }

  /// Check if property is in favorites
  Future<bool> isPropertyFavorited(String userId, String propertyId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('property_id', propertyId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Check favorite error: $e');
      return false;
    }
  }

  // ========== INQUIRY OPERATIONS ==========

  /// Create new inquiry
  Future<InquiryModel?> createInquiry({
    required String propertyId,
    required String userId,
    required String agentId,
    required String message,
  }) async {
    try {
      final response = await _client.from('inquiries').insert({
        'property_id': propertyId,
        'user_id': userId,
        'agent_id': agentId,
        'message': message,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select('''
        *,
        property:property_id(*),
        user:user_id(*)
      ''').maybeSingle();

      if (response == null) return null;

      return InquiryModel.fromMap(response);
    } catch (e) {
      print('Create inquiry error: $e');
      return null;
    }
  }

  /// Get inquiries for agent
  Future<List<InquiryModel>> getAgentInquiries(String agentId) async {
    try {
      final response = await _client
          .from('inquiries')
          .select('''
            *,
            property:property_id(*),
            user:user_id(*)
          ''')
          .eq('agent_id', agentId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InquiryModel.fromMap(json))
          .toList();
    } catch (e) {
      print('Get agent inquiries error: $e');
      return [];
    }
  }

  /// Get inquiries for user
  Future<List<InquiryModel>> getUserInquiries(String userId) async {
    try {
      final response = await _client
          .from('inquiries')
          .select('''
            *,
            property:property_id(*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InquiryModel.fromMap(json))
          .toList();
    } catch (e) {
      print('Get user inquiries error: $e');
      return [];
    }
  }

  /// Respond to inquiry
  Future<InquiryModel?> respondToInquiry({
    required String inquiryId,
    required String response,
  }) async {
    try {
      final result = await _client
          .from('inquiries')
          .update({
        'response': response,
        'status': 'responded',
        'responded_at': DateTime.now().toIso8601String(),
      })
          .eq('id', inquiryId)
          .select('''
            *,
            property:property_id(*),
            user:user_id(*)
          ''')
          .maybeSingle();

      if (result == null) return null;

      return InquiryModel.fromMap(result);
    } catch (e) {
      print('Respond to inquiry error: $e');
      return null;
    }
  }

  /// Update inquiry status
  Future<bool> updateInquiryStatus(String inquiryId, String status) async {
    try {
      await _client
          .from('inquiries')
          .update({'status': status})
          .eq('id', inquiryId);

      return true;
    } catch (e) {
      print('Update inquiry status error: $e');
      return false;
    }
  }

  // ========== ANALYTICS OPERATIONS ==========

  /// Get property statistics
  Future<Map<String, dynamic>> getPropertyStats({String? agentId}) async {
    try {
      var query = _client.from('properties').select('status');

      if (agentId != null) {
        query = query.eq('agent_id', agentId);
      }

      final response = await query;
      final properties = response as List;

      return {
        'total': properties.length,
        'available': properties.where((p) => p['status'] == 'available').length,
        'rented': properties.where((p) => p['status'] == 'rented').length,
        'pending': properties.where((p) => p['status'] == 'pending').length,
        'suspended': properties.where((p) => p['status'] == 'suspended').length,
      };
    } catch (e) {
      print('Get property stats error: $e');
      return {};
    }
  }

  /// Get user statistics (Admin only)
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _client.from('profiles').select('role, is_active');
      final users = response as List;

      return {
        'total': users.length,
        'active': users.where((u) => u['is_active'] == true).length,
        'inactive': users.where((u) => u['is_active'] == false).length,
        'tenants': users.where((u) => u['role'] == 'tenant').length,
        'agents': users.where((u) => u['role'] == 'agent').length,
        'landlords': users.where((u) => u['role'] == 'landlord').length,
        'admins': users.where((u) => u['role'] == 'admin').length,
      };
    } catch (e) {
      print('Get user stats error: $e');
      return {};
    }
  }

  /// Increment property views
  Future<bool> incrementPropertyViews(String propertyId) async {
    try {
      await _client.rpc('increment_property_views', params: {
        'property_id': propertyId,
      });
      return true;
    } catch (e) {
      // Fallback method if RPC function doesn't exist
      try {
        final property = await getPropertyById(propertyId);
        if (property != null) {
          await _client
              .from('properties')
              .update({'views': (property.views ?? 0) + 1})
              .eq('id', propertyId);
          return true;
        }
      } catch (fallbackError) {
        print('Increment property views fallback error: $fallbackError');
      }
      print('Increment property views error: $e');
      return false;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Check if service is properly initialized
  bool get isInitialized {
    try {
      return _supabaseUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current user session (if using Supabase Auth)
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated (if using Supabase Auth)
  bool get isAuthenticated => currentSession != null;
}

// Placeholder classes - you'll need to create these based on your needs
/*class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> images;
  final String? agentId;
  final String? landlordId;
  final String status;
  final int? views;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.images,
    this.agentId,
    this.landlordId,
    required this.status,
    this.views,
    required this.createdAt,
    this.updatedAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      location: map['location'] as String,
      bedrooms: map['bedrooms'] as int,
      bathrooms: map['bathrooms'] as int,
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      agentId: map['agent_id'] as String?,
      landlordId: map['landlord_id'] as String?,
      status: map['status'] as String,
      views: map['views'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}*/

/*class InquiryModel {
  final String id;
  final String propertyId;
  final String userId;
  final String agentId;
  final String message;
  final String? response;
  final String status;
  final DateTime? respondedAt;
  final DateTime createdAt;

  InquiryModel({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.agentId,
    required this.message,
    this.response,
    required this.status,
    this.respondedAt,
    required this.createdAt,
  });

  factory InquiryModel.fromMap(Map<String, dynamic> map) {
    return InquiryModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      userId: map['user_id'] as String,
      agentId: map['agent_id'] as String,
      message: map['message'] as String,
      response: map['response'] as String?,
      status: map['status'] as String,
      respondedAt: map['responded_at'] != null
          ? DateTime.parse(map['responded_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}*/