import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  admin,
  staff,
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? skinType;
  final String? skinSensitivity;
  final String? allergies;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  
  // Advanced AI Assistant Fields
  final String? hairType;
  final String? hairConcerns;
  final String? skinConcerns;
  final String? preferences;
  final List<String> recentTreatments;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    this.dateOfBirth,
    this.skinType,
    this.skinSensitivity,
    this.allergies,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.hairType,
    this.hairConcerns,
    this.skinConcerns,
    this.preferences,
    this.recentTreatments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'skinType': skinType,
      'skinSensitivity': skinSensitivity,
      'allergies': allergies,
      'notes': notes,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'hairType': hairType,
      'hairConcerns': hairConcerns,
      'skinConcerns': skinConcerns,
      'preferences': preferences,
      'recentTreatments': recentTreatments,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.byName(map['role'] ?? 'customer'),
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      skinType: map['skinType'],
      skinSensitivity: map['skinSensitivity'],
      allergies: map['allergies'],
      notes: map['notes'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      hairType: map['hairType'],
      hairConcerns: map['hairConcerns'],
      skinConcerns: map['skinConcerns'],
      preferences: map['preferences'],
      recentTreatments: List<String>.from(map['recentTreatments'] ?? []),
    );
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    UserRole? role,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? skinType,
    String? skinSensitivity,
    String? allergies,
    String? notes,
    bool? isActive,
    DateTime? lastLoginAt,
    String? hairType,
    String? hairConcerns,
    String? skinConcerns,
    String? preferences,
    List<String>? recentTreatments,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      skinType: skinType ?? this.skinType,
      skinSensitivity: skinSensitivity ?? this.skinSensitivity,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      hairType: hairType ?? this.hairType,
      hairConcerns: hairConcerns ?? this.hairConcerns,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      preferences: preferences ?? this.preferences,
      recentTreatments: recentTreatments ?? this.recentTreatments,
    );
  }
}
