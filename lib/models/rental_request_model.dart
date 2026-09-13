enum RentalRequestStatus { pending, approved, rejected, cancelled }

/// Data model representing a rental application / inquiry in DwellWise.
class RentalRequestModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String ownerId;
  final double proposedRent;
  final DateTime moveInDate;
  final RentalRequestStatus status;
  final String? message;
  final DateTime createdAt;

  RentalRequestModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.ownerId,
    required this.proposedRent,
    required this.moveInDate,
    required this.status,
    this.message,
    required this.createdAt,
  });

  /// Factory constructor to parse RentalRequestModel from JSON.
  factory RentalRequestModel.fromJson(Map<String, dynamic> json) {
    return RentalRequestModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      tenantId: json['tenant_id'] as String,
      ownerId: json['owner_id'] as String,
      proposedRent: (json['proposed_rent'] as num?)?.toDouble() ?? 0.0,
      moveInDate: DateTime.parse(json['move_in_date'] as String),
      status: _parseStatus(json['status'] as String?),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts RentalRequestModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'owner_id': ownerId,
      'proposed_rent': proposedRent,
      'move_in_date': moveInDate.toIso8601String(),
      'status': status.name,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static RentalRequestStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'approved':
        return RentalRequestStatus.approved;
      case 'rejected':
        return RentalRequestStatus.rejected;
      case 'cancelled':
        return RentalRequestStatus.cancelled;
      case 'pending':
      default:
        return RentalRequestStatus.pending;
    }
  }
}
