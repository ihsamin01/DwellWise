/// User roles in the DwellWise ecosystem.
enum UserRole { tenant, owner, admin }

/// Data model representing a user in the DwellWise app.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String? avatarUrl;
  final String? address;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl,
    this.address,
    required this.createdAt,
  });

  /// Factory constructor to parse UserModel from JSON map (e.g. Supabase response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts UserModel to JSON map for database operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'role': role.name,
      'avatar_url': avatarUrl,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? address,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'tenant':
      default:
        return UserRole.tenant;
    }
  }
}
