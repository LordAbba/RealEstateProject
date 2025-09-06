// models/property_model.dart

class PropertyModel {
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
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorited;

  // Additional fields for display
  final String? agentName;
  final String? agentPhone;
  final String? agentEmail;
  final String? landlordName;

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
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorited = false,
    this.agentName,
    this.agentPhone,
    this.agentEmail,
    this.landlordName,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      agentId: json['agent_id'],
      landlordId: json['landlord_id'],
      status: json['status'],
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isFavorited: json['is_favorited'] ?? false,
      agentName: json['agent_name'],
      agentPhone: json['agent_phone'],
      agentEmail: json['agent_email'],
      landlordName: json['landlord_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'status': status,
      'views': views,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
    List<String>? images,
    String? agentId,
    String? landlordId,
    String? status,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorited,
    String? agentName,
    String? agentPhone,
    String? agentEmail,
    String? landlordName,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      agentId: agentId ?? this.agentId,
      landlordId: landlordId ?? this.landlordId,
      status: status ?? this.status,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorited: isFavorited ?? this.isFavorited,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agentEmail: agentEmail ?? this.agentEmail,
      landlordName: landlordName ?? this.landlordName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PropertyModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PropertyModel{id: $id, title: $title, price: $price, location: $location}';
  }
}