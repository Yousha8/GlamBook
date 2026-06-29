import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ServiceModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> galleryUrls;
  final double price;
  final int durationMinutes;
  final bool isFeatured;
  final bool isPopular;
  final bool isActive;
  final String? precautions;
  final List<String> suitabilityTags;
  
  // Advanced AI Assistant Fields
  final List<String> targetConcerns;
  final List<String> contraindicationTags;
  final List<String> recommendedSkinTypes;
  final List<String> recommendedHairTypes;
  final List<String> notRecommendedFor;
  final List<String> benefits;
  final bool requiresConsultation;

  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.galleryUrls = const [],
    required this.price,
    required this.durationMinutes,
    this.isFeatured = false,
    this.isPopular = false,
    this.isActive = true,
    this.precautions,
    this.suitabilityTags = const [],
    this.targetConcerns = const [],
    this.contraindicationTags = const [],
    this.recommendedSkinTypes = const [],
    this.recommendedHairTypes = const [],
    this.notRecommendedFor = const [],
    this.benefits = const [],
    this.requiresConsultation = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'price': price,
      'durationMinutes': durationMinutes,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'isActive': isActive,
      'precautions': precautions,
      'suitabilityTags': suitabilityTags,
      'targetConcerns': targetConcerns,
      'contraindicationTags': contraindicationTags,
      'recommendedSkinTypes': recommendedSkinTypes,
      'recommendedHairTypes': recommendedHairTypes,
      'notRecommendedFor': notRecommendedFor,
      'benefits': benefits,
      'requiresConsultation': requiresConsultation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceModel(
      id: docId,
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 30,
      isFeatured: map['isFeatured'] ?? false,
      isPopular: map['isPopular'] ?? false,
      isActive: map['isActive'] ?? true,
      precautions: map['precautions'],
      suitabilityTags: List<String>.from(map['suitabilityTags'] ?? []),
      targetConcerns: List<String>.from(map['targetConcerns'] ?? []),
      contraindicationTags: List<String>.from(map['contraindicationTags'] ?? []),
      recommendedSkinTypes: List<String>.from(map['recommendedSkinTypes'] ?? []),
      recommendedHairTypes: List<String>.from(map['recommendedHairTypes'] ?? []),
      notRecommendedFor: List<String>.from(map['notRecommendedFor'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      requiresConsultation: map['requiresConsultation'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
