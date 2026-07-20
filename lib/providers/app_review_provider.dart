import 'package:flutter/material.dart';
import '../models/app_review_model.dart';

/// Provider handling locally-stored "Rate the App" reviews.
class AppReviewProvider with ChangeNotifier {
  final List<AppReviewModel> _reviews = [
    AppReviewModel(
      id: 'r1',
      userName: 'Farhan Kabir',
      rating: 5,
      reviewText: 'Finding a flat in Dhaka has never been this easy. Great app!',
      createdAt: DateTime(2026, 6, 2),
    ),
    AppReviewModel(
      id: 'r2',
      userName: 'Tania Islam',
      rating: 4,
      reviewText: 'Very helpful for searching by location. Could use more filters.',
      createdAt: DateTime(2026, 6, 18),
    ),
  ];

  List<AppReviewModel> get reviews => List.unmodifiable(_reviews.reversed);

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  void addReview({required String userName, required double rating, required String reviewText}) {
    _reviews.add(
      AppReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: userName,
        rating: rating,
        reviewText: reviewText,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
