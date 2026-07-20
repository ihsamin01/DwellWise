/// Data model representing a user's rating/review of the DwellWise app itself.
class AppReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String reviewText;
  final DateTime createdAt;

  const AppReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });
}
