import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/bento_photo_grid.dart';
import '../../data/models/property_model.dart';
import '../providers/property_provider.dart';

class CreateListingPage extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const CreateListingPage({
    Key? key,
    required this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends ConsumerState<CreateListingPage> {
  int _currentStep = 1;
  int _uploadedPhotosCount = 0;

  // Form Fields State
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _facilities = [];
  bool _isLoading = false;

  void _nextStep() {
    if (_currentStep == 1) {
      if (_uploadedPhotosCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least the cover photo to proceed.')),
        );
        return;
      }
      if (_formKey1.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 2) {
      if (_formKey2.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 3) {
      if (_formKey3.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitListing() {
    setState(() {
      _isLoading = true;
    });

    // Simulate listing registration delay
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        // Create new property object
        final newProperty = Property(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          area: '${_areaController.text.trim()}, Dhaka',
          price: double.tryParse(_priceController.text) ?? 35000,
          rating: 4.5,
          beds: int.tryParse(_bedsController.text) ?? 2,
          baths: 2,
          sizeSqFt: double.tryParse(_sizeController.text) ?? 1100,
          imageUrl: 'vector_new',
          isVerified: true, // Auto-verified for presentation transparency demo
          ownerName: 'Samin Azhan',
          ownerPhone: '+880 1712-345678',
          ownerImage: 'SA',
          description: _descriptionController.text.trim(),
          facilities: ['Wifi', 'Parking', 'Lift', 'Backup'],
          latitude: 23.795, // Center coordinate default
          longitude: 90.410,
        );

        // Add to global state
        ref.read(propertiesProvider.notifier).addProperty(newProperty);

        setState(() {
          _isLoading = false;
        });

        // Trigger success callback
        widget.onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property listed successfully! Verified with trust index.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _bedsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List a Property'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Progress indicator header
          _buildStepProgressIndicator(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: _buildActiveStepForm(),
            ),
          ),
          
          // Sticky Bottom navigation buttons
          _buildFooterButtons(),
        ],
      ),
    );
  }

  Widget _buildStepProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.lowest,
      child: Row(
        children: List.generate(4, (index) {
          final stepNum = index + 1;
          final isCompleted = _currentStep > stepNum;
          final isActive = _currentStep == stepNum;

          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : isActive
                            ? AppColors.secondary
                            : AppColors.high,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            color: isActive || isCompleted ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isCompleted ? AppColors.primary : AppColors.high,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveStepForm() {
    switch (_currentStep) {
      case 1:
        return Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Step 1: Upload Photos & Location', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Upload visual proof of your property. We recommend clear shots of the living room, bedrooms, and toilets.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),
              
              // Bento photo selection grid
              BentoPhotoGrid(
                onPhotosChanged: (count) {
                  setState(() {
                    _uploadedPhotosCount = count;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Location info
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Neighborhood',
                  hintText: 'e.g. Gulshan 1, Banani, Uttara Sector 3',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Area is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Guide Tile with verified examples
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DwellWise Verification Guide',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Listed properties are automatically run through spatial verification checks. Fake locations or stock photos will be rejected.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 2:
        return Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Step 2: Core Details & Dimension', style: AppTextStyles.titleMedium),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Listing Title',
                  hintText: 'e.g. Modern Furnished Penthouse',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Size (sq ft)',
                        hintText: 'e.g. 1400',
                        prefixIcon: Icon(Icons.square_foot),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _bedsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bedrooms',
                        hintText: 'e.g. 3',
                        prefixIcon: Icon(Icons.bed_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  hintText: 'Describe amenities, security features, parking access, surroundings...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Description is required';
                  if (val.length < 20) return 'Must be at least 20 characters';
                  return null;
                },
              ),
            ],
          ),
        );
      case 3:
        return Form(
          key: _formKey3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Step 3: Rent & Facility Checks', style: AppTextStyles.titleMedium),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Expected Monthly Rent (BDT)',
                  hintText: 'e.g. 45000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Rent price is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                'Check all services ready at location:',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 12),
              
              _buildCheckboxTile('Wifi Internet Available'),
              _buildCheckboxTile('Dedicated Car Parking Slot'),
              _buildCheckboxTile('24/7 Elevator / Lift'),
              _buildCheckboxTile('Standby Generator Backup'),
            ],
          ),
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Step 4: Verification Statement', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            const Center(
              child: Icon(
                Icons.verified_user_rounded,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transparency Commitment',
              style: AppTextStyles.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'By hitting submit, you guarantee that this listing represents a real, non-duplicate property with clean legal titles. DwellWise will run a verification check and contact you within 2 hours to activate the listing pins.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.6, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.high.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Listing Owner', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 2),
                        const Text('Samin Azhan (+880 1712-345678)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildCheckboxTile(String label) {
    return CheckboxListTile(
      value: true,
      onChanged: (val) {},
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildFooterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 1) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _currentStep == 4 ? 'Confirm & Publish' : 'Continue',
                isLoading: _isLoading,
                isPrimary: _currentStep == 4, // uses primary green for submit
                onPressed: _currentStep == 4 ? _submitListing : _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
