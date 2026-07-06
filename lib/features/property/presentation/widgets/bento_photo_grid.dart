import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class BentoPhotoGrid extends StatefulWidget {
  final ValueChanged<int> onPhotosChanged;

  const BentoPhotoGrid({
    Key? key,
    required this.onPhotosChanged,
  }) : super(key: key);

  @override
  State<BentoPhotoGrid> createState() => _BentoPhotoGridState();
}

class _BentoPhotoGridState extends State<BentoPhotoGrid> {
  // Store the mock upload state of 4 slots (false = empty, true = simulated uploaded)
  final List<bool> _slots = [false, false, false, false];

  void _toggleSlot(int index) {
    setState(() {
      _slots[index] = !_slots[index];
    });
    // Notify parent about the number of selected photos
    final selectedCount = _slots.where((uploaded) => uploaded).length;
    widget.onPhotosChanged(selectedCount);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // 1. Large Cover Photo Slot (Main grid item)
          Expanded(
            flex: 6,
            child: _buildUploadSlot(
              index: 0,
              label: 'Cover Photo',
              isLarge: true,
            ),
          ),
          const SizedBox(width: 12),
          // 2. Right Side Smaller Photo Slots (vertical column of 3 items)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: _buildUploadSlot(
                    index: 1,
                    label: 'Living room',
                    isLarge: false,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildUploadSlot(
                    index: 2,
                    label: 'Bedroom',
                    isLarge: false,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildUploadSlot(
                    index: 3,
                    label: 'Washroom',
                    isLarge: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSlot({
    required int index,
    required String label,
    required bool isLarge,
  }) {
    final isUploaded = _slots[index];

    return GestureDetector(
      onTap: () => _toggleSlot(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.primary.withOpacity(0.08) : AppColors.lowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primary : AppColors.high,
            width: isUploaded ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isUploaded
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Vector pattern indicating selected image state
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      color: AppColors.primary.withOpacity(0.12),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: isLarge ? 36 : 22,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      '$label Loaded',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: isLarge ? 11 : 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.textLight,
                    size: isLarge ? 32 : 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isLarge ? 11 : 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
