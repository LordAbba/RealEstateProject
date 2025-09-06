// services/property_service.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Models/PropertyModel.dart';
import '../Services/SupaBaseService.dart';

class PropertyService extends GetxService {
  late final SupabaseClient _client;

  Future<PropertyService> init() async {
    _client = Get.find<SupabaseService>().client;
    return this;
  }

  /// Get all available properties for tenants to browse
  Future<List<PropertyModel>> getAvailableProperties({
    String? userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'available')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;

      // If user is provided, check favorites
      List<String> favoriteIds = [];
      if (userId != null) {
        final favoritesResponse = await _client
            .from('favorites')
            .select('property_id')
            .eq('user_id', userId);

        favoriteIds = (favoritesResponse as List)
            .map((item) => item['property_id'] as String)
            .toList();
      }

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'is_favorited': favoriteIds.contains(json['id']),
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch available properties: $e');
    }
  }

  /// Get featured properties for dashboard
  Future<List<PropertyModel>> getFeaturedProperties({
    String? userId,
    int limit = 6,
  }) async {
    try {
      var query = _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'available')
          .order('views', ascending: false)
          .limit(limit);

      final response = await query;

      // If user is provided, check favorites
      List<String> favoriteIds = [];
      if (userId != null) {
        final favoritesResponse = await _client
            .from('favorites')
            .select('property_id')
            .eq('user_id', userId);

        favoriteIds = (favoritesResponse as List)
            .map((item) => item['property_id'] as String)
            .toList();
      }

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'is_favorited': favoriteIds.contains(json['id']),
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch featured properties: $e');
    }
  }

  /// Get properties by agent or landlord
  Future<List<PropertyModel>> getPropertiesByUser(String userId) async {
    try {
      final response = await _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .or('agent_id.eq.$userId,landlord_id.eq.$userId')
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch user properties: $e');
    }
  }

  /// Get single property by ID
  Future<PropertyModel?> getPropertyById(String propertyId, {String? userId}) async {
    try {
      final response = await _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('id', propertyId)
          .single();

      // Check if user has favorited this property
      bool isFavorited = false;
      if (userId != null) {
        final favoriteResponse = await _client
            .from('favorites')
            .select('id')
            .eq('user_id', userId)
            .eq('property_id', propertyId)
            .maybeSingle();

        isFavorited = favoriteResponse != null;
      }

      return PropertyModel.fromJson({
        ...response,
        'is_favorited': isFavorited,
        'agent_name': response['agent']?['full_name'],
        'agent_phone': response['agent']?['phone'],
        'agent_email': response['agent']?['email'],
        'landlord_name': response['landlord']?['full_name'],
      });

    } catch (e) {
      if (e.toString().contains('No rows found')) {
        return null;
      }
      throw Exception('Failed to fetch property: $e');
    }
  }

  /// Add new property
  Future<PropertyModel> addProperty(PropertyModel property) async {
    try {
      final response = await _client
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();

      return PropertyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add property: $e');
    }
  }

  /// Update property
  Future<PropertyModel> updateProperty(String propertyId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('properties')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', propertyId)
          .select()
          .single();

      return PropertyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  /// Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _client
          .from('properties')
          .delete()
          .eq('id', propertyId);
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  /// Toggle favorite property
  Future<void> toggleFavorite(String userId, String propertyId) async {
    try {
      // Check if already favorited
      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('property_id', propertyId)
          .maybeSingle();

      if (existing != null) {
        // Remove from favorites
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('property_id', propertyId);
      } else {
        // Add to favorites
        await _client
            .from('favorites')
            .insert({
          'user_id': userId,
          'property_id': propertyId,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Get user favorites
  Future<List<PropertyModel>> getUserFavorites(String userId) async {
    try {
      final response = await _client
          .from('favorites')
          .select('''
            property:properties (
              *,
              agent:profiles!agent_id(full_name, phone, email),
              landlord:profiles!landlord_id(full_name)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .where((item) => item['property'] != null)
          .map((item) {
        final property = item['property'];
        return PropertyModel.fromJson({
          ...property,
          'is_favorited': true,
          'agent_name': property['agent']?['full_name'],
          'agent_phone': property['agent']?['phone'],
          'agent_email': property['agent']?['email'],
          'landlord_name': property['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  /// Increment property views
  Future<void> incrementPropertyViews(String propertyId) async {
    try {
      await _client.rpc('increment_property_views', params: {
        'property_id': propertyId,
      });
    } catch (e) {
      // Don't throw error for view increment failures
      print('Failed to increment views: $e');
    }
  }

  /// Search properties with filters
  Future<List<PropertyModel>> searchProperties({
    String? searchQuery,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? minBathrooms,
    String? userId,
    int limit = 50,
  }) async {
    try {
      var query = _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'available');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%,location.ilike.%$searchQuery%');
      }

      if (location != null && location.isNotEmpty) {
        query = query.ilike('location', '%$location%');
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (minBedrooms != null) {
        query = query.gte('bedrooms', minBedrooms);
      }

      if (minBathrooms != null) {
        query = query.gte('bathrooms', minBathrooms);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      // Check favorites if user is provided
      List<String> favoriteIds = [];
      if (userId != null) {
        final favoritesResponse = await _client
            .from('favorites')
            .select('property_id')
            .eq('user_id', userId);

        favoriteIds = (favoritesResponse as List)
            .map((item) => item['property_id'] as String)
            .toList();
      }

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'is_favorited': favoriteIds.contains(json['id']),
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }

  /// Get property statistics for dashboard
  Future<Map<String, dynamic>> getPropertyStats(String userId) async {
    try {
      final response = await _client
          .from('properties')
          .select('status')
          .or('agent_id.eq.$userId,landlord_id.eq.$userId');

      final properties = response as List;
      final total = properties.length;
      final available = properties.where((p) => p['status'] == 'available').length;
      final rented = properties.where((p) => p['status'] == 'rented').length;
      final pending = properties.where((p) => p['status'] == 'pending').length;

      return {
        'total': total,
        'available': available,
        'rented': rented,
        'pending': pending,
        'occupancy_rate': total > 0 ? (rented / total * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch property stats: $e');
    }
  }

  /// Get properties by category/type (additional utility method)
  Future<List<PropertyModel>> getPropertiesByCategory({
    required String category,
    String? userId,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'available')
          .contains('amenities', [category])
          .order('created_at', ascending: false)
          .limit(limit);

      final response = await query;

      // Check favorites if user is provided
      List<String> favoriteIds = [];
      if (userId != null) {
        final favoritesResponse = await _client
            .from('favorites')
            .select('property_id')
            .eq('user_id', userId);

        favoriteIds = (favoritesResponse as List)
            .map((item) => item['property_id'] as String)
            .toList();
      }

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'is_favorited': favoriteIds.contains(json['id']),
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch properties by category: $e');
    }
  }

  /// Get recently added properties
  Future<List<PropertyModel>> getRecentProperties({
    String? userId,
    int limit = 10,
  }) async {
    try {
      var query = _client
          .from('properties')
          .select('''
            *,
            agent:profiles!agent_id(full_name, phone, email),
            landlord:profiles!landlord_id(full_name)
          ''')
          .eq('status', 'available')
          .gte('created_at', DateTime.now().subtract(Duration(days: 7)).toIso8601String())
          .order('created_at', ascending: false)
          .limit(limit);

      final response = await query;

      // Check favorites if user is provided
      List<String> favoriteIds = [];
      if (userId != null) {
        final favoritesResponse = await _client
            .from('favorites')
            .select('property_id')
            .eq('user_id', userId);

        favoriteIds = (favoritesResponse as List)
            .map((item) => item['property_id'] as String)
            .toList();
      }

      return (response as List).map((json) {
        return PropertyModel.fromJson({
          ...json,
          'is_favorited': favoriteIds.contains(json['id']),
          'agent_name': json['agent']?['full_name'],
          'agent_phone': json['agent']?['phone'],
          'agent_email': json['agent']?['email'],
          'landlord_name': json['landlord']?['full_name'],
        });
      }).toList();

    } catch (e) {
      throw Exception('Failed to fetch recent properties: $e');
    }
  }
}