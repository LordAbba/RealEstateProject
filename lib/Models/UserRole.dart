import 'package:equatable/equatable.dart';

enum UserRole { tenant, agent, landlord, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final bool isVerified;
  final String? profileImage;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.isVerified = false,
    this.profileImage,
    this.additionalData,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert from Map (from database)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      phone: map['phone'],
      role: UserRole.values.firstWhere(
            (r) => r.toString().split('.').last == map['role'],
        orElse: () => UserRole.tenant,
      ),
      isVerified: map['is_verified'] ?? false,
      profileImage: map['profile_image'],
      additionalData: map['additional_data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Convert from JSON (alias for fromMap for consistency)
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.toString().split('.').last,
      'is_verified': isVerified,
      'profile_image': profileImage,
      'additional_data': additionalData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON (alias for toMap for consistency)
  Map<String, dynamic> toJson() => toMap();

  // Copy with modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    bool? isVerified,
    String? profileImage,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      profileImage: profileImage ?? this.profileImage,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String get displayName => fullName.isNotEmpty ? fullName : email;
  bool get isAgent => role == UserRole.agent;
  bool get isLandlord => role == UserRole.landlord;
  bool get isTenant => role == UserRole.tenant;
  bool get isAdmin => role == UserRole.admin;
  String get roleDisplay => role.toString().split('.').last.toUpperCase();

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    role,
    isVerified,
    profileImage,
    additionalData,
    createdAt,
    updatedAt,
  ];
}

// Property Models
enum PropertyStatus { available, rented, pending, suspended }
enum PropertyType { apartment, house, duplex, studio, townhouse }

class PropertyModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final int bathrooms;
  final PropertyType type;
  final PropertyStatus status;
  final List<String> amenities;
  final List<String> images;
  final String agentId;
  final String? landlordId;
  final bool isApproved;
  final String? rejectionReason;
  final int views;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserModel? agent; // Added for joined data
  final UserModel? landlord; // Added for joined data

  const PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.type,
    this.status = PropertyStatus.pending,
    this.amenities = const [],
    this.images = const [],
    required this.agentId,
    this.landlordId,
    this.isApproved = false,
    this.rejectionReason,
    this.views = 0,
    required this.createdAt,
    this.updatedAt,
    this.agent,
    this.landlord,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      type: PropertyType.values.firstWhere(
            (t) => t.toString().split('.').last == map['type'],
        orElse: () => PropertyType.apartment,
      ),
      status: PropertyStatus.values.firstWhere(
            (s) => s.toString().split('.').last == map['status'],
        orElse: () => PropertyStatus.pending,
      ),
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      agentId: map['agent_id'] ?? '',
      landlordId: map['landlord_id'],
      isApproved: map['is_approved'] ?? false,
      rejectionReason: map['rejection_reason'],
      views: map['views'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      agent: map['agent'] != null ? UserModel.fromMap(map['agent']) : null,
      landlord: map['landlord'] != null ? UserModel.fromMap(map['landlord']) : null,
    );
  }

  // Convert from JSON (alias for fromMap)
  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amenities': amenities,
      'images': images,
      'agent_id': agentId,
      'landlord_id': landlordId,
      'is_approved': isApproved,
      'rejection_reason': rejectionReason,
      'views': views,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON (alias for toMap)
  Map<String, dynamic> toJson() => toMap();

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    PropertyType? type,
    PropertyStatus? status,
    List<String>? amenities,
    List<String>? images,
    String? agentId,
    String? landlordId,
    bool? isApproved,
    String? rejectionReason,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? agent,
    UserModel? landlord,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      type: type ?? this.type,
      status: status ?? this.status,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      agentId: agentId ?? this.agentId,
      landlordId: landlordId ?? this.landlordId,
      isApproved: isApproved ?? this.isApproved,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      agent: agent ?? this.agent,
      landlord: landlord ?? this.landlord,
    );
  }

  // Helper getters
  String get formattedPrice => '₦${price.toStringAsFixed(0)}';
  String get propertyTypeDisplay => type.toString().split('.').last.toUpperCase();
  String get statusDisplay => status.toString().split('.').last.toUpperCase();
  bool get isAvailable => status == PropertyStatus.available;
  bool get isPending => status == PropertyStatus.pending;
  String get bedroomBathroomText => '${bedrooms}BR • ${bathrooms}BA';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    price,
    location,
    address,
    latitude,
    longitude,
    bedrooms,
    bathrooms,
    type,
    status,
    amenities,
    images,
    agentId,
    landlordId,
    isApproved,
    rejectionReason,
    views,
    createdAt,
    updatedAt,
    agent,
    landlord,
  ];
}

// OTP Model
enum OTPType { registration, login, passwordReset }

class OTPModel extends Equatable {
  final String id;
  final String email;
  final String code;
  final OTPType type;
  final bool isUsed;
  final DateTime expiresAt;
  final DateTime createdAt;

  const OTPModel({
    required this.id,
    required this.email,
    required this.code,
    required this.type,
    this.isUsed = false,
    required this.expiresAt,
    required this.createdAt,
  });

  factory OTPModel.fromMap(Map<String, dynamic> map) {
    return OTPModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      code: map['code'] ?? '',
      type: OTPType.values.firstWhere(
            (t) => t.toString().split('.').last == map['type'],
        orElse: () => OTPType.login,
      ),
      isUsed: map['is_used'] ?? false,
      expiresAt: DateTime.parse(map['expires_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory OTPModel.fromJson(Map<String, dynamic> json) => OTPModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'code': code,
      'type': type.toString().split('.').last,
      'is_used': isUsed,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;

  @override
  List<Object?> get props => [id, email, code, type, isUsed, expiresAt, createdAt];
}

// Favorite Model
class FavoriteModel extends Equatable {
  final String id;
  final String userId;
  final String propertyId;
  final DateTime createdAt;
  final PropertyModel? property;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdAt,
    this.property,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      propertyId: map['property_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      property: map['properties'] != null
          ? PropertyModel.fromMap(map['properties'])
          : null,
    );
  }

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  @override
  List<Object?> get props => [id, userId, propertyId, createdAt, property];
}

// Inquiry Model
enum InquiryStatus { pending, responded, resolved, closed }

class InquiryModel extends Equatable {
  final String id;
  final String propertyId;
  final String userId;
  final String agentId;
  final String message;
  final InquiryStatus status;
  final String? response;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final PropertyModel? property;
  final UserModel? user;

  const InquiryModel({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.agentId,
    required this.message,
    this.status = InquiryStatus.pending,
    this.response,
    required this.createdAt,
    this.respondedAt,
    this.property,
    this.user,
  });

  factory InquiryModel.fromMap(Map<String, dynamic> map) {
    return InquiryModel(
      id: map['id'] ?? '',
      propertyId: map['property_id'] ?? '',
      userId: map['user_id'] ?? '',
      agentId: map['agent_id'] ?? '',
      message: map['message'] ?? '',
      status: InquiryStatus.values.firstWhere(
            (s) => s.toString().split('.').last == map['status'],
        orElse: () => InquiryStatus.pending,
      ),
      response: map['response'],
      createdAt: DateTime.parse(map['created_at']),
      respondedAt: map['responded_at'] != null
          ? DateTime.parse(map['responded_at'])
          : null,
      property: map['properties'] != null
          ? PropertyModel.fromMap(map['properties'])
          : null,
      user: map['users'] != null
          ? UserModel.fromMap(map['users'])
          : null,
    );
  }

  factory InquiryModel.fromJson(Map<String, dynamic> json) => InquiryModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'user_id': userId,
      'agent_id': agentId,
      'message': message,
      'status': status.toString().split('.').last,
      'response': response,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  InquiryModel copyWith({
    String? id,
    String? propertyId,
    String? userId,
    String? agentId,
    String? message,
    InquiryStatus? status,
    String? response,
    DateTime? createdAt,
    DateTime? respondedAt,
    PropertyModel? property,
    UserModel? user,
  }) {
    return InquiryModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      message: message ?? this.message,
      status: status ?? this.status,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      property: property ?? this.property,
      user: user ?? this.user,
    );
  }

  bool get isPending => status == InquiryStatus.pending;
  bool get isResponded => status == InquiryStatus.responded;
  String get statusDisplay => status.toString().split('.').last.toUpperCase();

  @override
  List<Object?> get props => [
    id,
    propertyId,
    userId,
    agentId,
    message,
    status,
    response,
    createdAt,
    respondedAt,
    property,
    user,
  ];
}