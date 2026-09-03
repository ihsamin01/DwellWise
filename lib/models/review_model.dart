/// Data model representing a property review by a tenant in DwellWise.
class ReviewModel {
  final String id;
  final String propertyId;
  final String tenantId;
  final String tenantName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.tenantName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Factory constructor to parse ReviewModel from JSON.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      tenantId: json['tenant_id'] as String,
      tenantName: json['tenant_name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// Converts ReviewModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
