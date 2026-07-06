import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? attachmentName; // Optional attachment (e.g. 'Floor Plan.png')

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isMe,
    this.attachmentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Attachment Box if present
          if (attachmentName != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6, top: 4),
              padding: const EdgeInsets.all(12),
              width: 220,
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary.withOpacity(0.08) : AppColors.low,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMe ? AppColors.primary.withOpacity(0.2) : AppColors.high,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.lowest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      color: isMe ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachmentName!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Floor Plan Attachment',
                          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_circle_down_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ],
          
          // Main text bubble
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.low,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
