import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/app_review_provider.dart';
import '../../providers/user_provider.dart';

/// Lets the user leave a star rating and written review for the app itself,
/// stored locally via [AppReviewProvider].
class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  final _reviewController = TextEditingController();
  int _selectedRating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }

    final userName = context.read<UserProvider>().userModel?.name ?? 'You';
    context.read<AppReviewProvider>().addReview(
          userName: userName,
          rating: _selectedRating.toDouble(),
          reviewText: _reviewController.text.trim(),
        );

    setState(() {
      _selectedRating = 0;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for your review!'), backgroundColor: Color(0xff10B981)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<AppReviewProvider>().reviews;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate the App')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('How would you rate DwellWise?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                iconSize: 36,
                onPressed: () => setState(() => _selectedRating = starIndex),
                icon: Icon(
                  starIndex <= _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(onPressed: _submit, child: const Text('Submit')),
          ),
          const SizedBox(height: 28),
          Text('${reviews.length} Reviews', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          for (final review in reviews)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          DateFormat('d MMM yyyy').format(review.createdAt),
                          style: const TextStyle(fontSize: 12, color: Color(0xff6B7280)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    if (review.reviewText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(review.reviewText),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
