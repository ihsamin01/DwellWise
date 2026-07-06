import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/price_range_slider.dart';

class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({Key? key}) : super(key: key);

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  RangeValues _priceRange = const RangeValues(15000, 90000);
  String _selectedCategory = 'Apartment';
  int _selectedBeds = 2;
  final List<String> _selectedFacilities = [];

  final List<String> _categories = ['Apartment', 'Studio', 'Duplex', 'Commercial', 'Sublet'];
  final List<int> _bedsOptions = [1, 2, 3, 4, 5];
  final List<String> _facilitiesOptions = ['Wifi', 'Parking', 'Lift', 'Backup', 'Gym', 'Pool', 'Security'];

  void _toggleFacility(String facility) {
    setState(() {
      if (_selectedFacilities.contains(facility)) {
        _selectedFacilities.remove(facility);
      } else {
        _selectedFacilities.add(facility);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Filter Properties'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(15000, 90000);
                _selectedCategory = 'Apartment';
                _selectedBeds = 2;
                _selectedFacilities.clear();
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selector Section
            Text(
              'Property Category',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.high, // high container for inactive
                  disabledColor: AppColors.high,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.high,
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Budget Limits Section
            Text(
              'Monthly Budget (BDT)',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 16),
            PriceRangeSlider(
              values: _priceRange,
              min: 10000,
              max: 150000,
              onChanged: (newValues) {
                setState(() {
                  _priceRange = newValues;
                });
              },
            ),
            const SizedBox(height: 28),

            // Bedrooms count section
            Text(
              'Bedrooms (BHK)',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _bedsOptions.map((beds) {
                final isSelected = _selectedBeds == beds;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBeds = beds;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.lowest,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.high,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$beds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Facilities Section
            Text(
              'Facilities & Amenities',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _facilitiesOptions.map((fac) {
                final isSelected = _selectedFacilities.contains(fac);
                return FilterChip(
                  label: Text(fac),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    _toggleFacility(fac);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.lowest,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.high,
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Apply CTA Button
            CustomButton(
              text: 'Apply Filters',
              isPrimary: false, // uses secondary #FEA619 for CTA
              onPressed: () {
                // Return to dashboard page with filter settings
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
