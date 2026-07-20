/// User roles in the DwellWise ecosystem.
enum UserRole { tenant, owner, admin }

/// Account verification lifecycle. [pending] means the user submitted the
/// verification form + fee and is awaiting admin approval; [verified] earns
/// the green trust badge (Facebook-style).
enum VerificationStatus { unverified, pending, verified }

/// Data model representing a user in the DwellWise app.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final String? avatarUrl;
  final String? address;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl,
    this.address,
    this.verificationStatus = VerificationStatus.unverified,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

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
      verificationStatus: _parseVerification(json['verification_status'] as String?),
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
      'verification_status': verificationStatus.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? address,
    UserRole? role,
    VerificationStatus? verificationStatus,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      verificationStatus: verificationStatus ?? this.verificationStatus,
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

  static VerificationStatus _parseVerification(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'unverified':
      default:
        return VerificationStatus.unverified;
    }
  }
}
