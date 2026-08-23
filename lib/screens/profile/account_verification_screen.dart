import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';

/// Account verification.
class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nidController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  /// NID photos attached by the user; uploaded to Storage on submit.
  File? _frontImage;
  File? _backImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().userModel;
    _fullNameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nidController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  /// Lets the user attach an NID photo from the camera or the gallery.
  Future<void> _pickDocument({required bool isFront}) async {
    final colors = AppColors.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: colors.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: colors.primary),
              title: const Text('Take a photo'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: colors.primary),
              title: const Text('Choose from gallery'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final shot = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (shot == null || !mounted) return;
      setState(() {
        if (isFront) {
          _frontImage = File(shot.path);
        } else {
          _backImage = File(shot.path);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not attach that photo.')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'av_attach_both'))),
      );
      return;
    }

    final confirmed = await _showPaymentSheet();
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final ok = await context.read<UserProvider>().submitVerification(
          governmentId: _nidController.text.trim(),
          documents: [_frontImage!, _backImage!],
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification could not be completed. Try again.'),
          backgroundColor: Color(0xffDC2626),
        ),
      );
      return;
    }

    // Drop it in the in-app notification inbox as well.
    context.read<NotificationProvider>().addNotification(
          kind: NotificationKind.verification,
          title: 'Account verified',
          message:
              'Your identity has been verified. The green badge now shows on your profile.',
        );

    await _showVerifiedDialog();
    if (!mounted) return;
    context.go('/profile');
  }

  Future<void> _showVerifiedDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified, color: Color(0xff10B981), size: 52),
        title: const Text('Account verified'),
        content: const Text(
          'Payment received and your identity is confirmed. '
          'Your profile now carries the verified badge.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff1877F2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPaymentSheet() {
    final colors = AppColors.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t(sheetContext, 'av_fee_title'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                AppStrings.t(sheetContext, 'av_fee_desc'),
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.t(sheetContext, 'av_amount_payable'),
                        style: TextStyle(color: colors.textSecondary)),
                    Text('৳${AppStrings.digits(sheetContext, '200')}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: Text(AppStrings.t(sheetContext, 'av_pay_now')),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(AppStrings.t(sheetContext, 'av_mock_payment'),
                    style: TextStyle(fontSize: 11, color: colors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final status = context.watch<UserProvider>().verificationStatus;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(AppStrings.t(context, 'p_acc_verif'))),
      // SafeArea keeps the submit button clear of the device's bottom.
      body: SafeArea(
        child: status == VerificationStatus.unverified
            ? _buildForm(colors)
            : _buildStatusView(colors, status),
      ),
    );
  }

  Widget _buildStatusView(AppColors colors, VerificationStatus status) {
    final verified = status == VerificationStatus.verified;
    final color = verified ? const Color(0xff10B981) : const Color(0xff1877F2);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(verified ? Icons.verified : Icons.hourglass_top, size: 72, color: color),
            const SizedBox(height: 16),
            Text(
              AppStrings.t(context, verified ? 'av_verified_title' : 'av_pending_title'),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.t(context, verified ? 'av_verified_desc' : 'av_pending_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            // Debug-only shortcut so the green badge can be demoed without an.
            if (!verified && kDebugMode) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.read<UserProvider>().approveVerification(),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: Text(AppStrings.t(context, 'av_simulate')),
              ),
              const SizedBox(height: 4),
              Text(
                'Debug builds only',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppColors colors) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.t(context, 'av_info'),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _RequiredLabel(AppStrings.t(context, 'av_fullname'), colors),
          _field(_fullNameController, AppStrings.t(context, 'av_fullname_hint'),
              Icons.person_outline),
          const SizedBox(height: 16),
          _RequiredLabel(AppStrings.t(context, 'av_nid'), colors),
          _field(_nidController, AppStrings.t(context, 'av_nid_hint'), Icons.badge_outlined,
              keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _RequiredLabel(AppStrings.t(context, 'av_dob'), colors),
          _field(_dobController, 'DD/MM/YYYY', Icons.calendar_today_outlined,
              readOnly: true, onTap: _pickDob),
          const SizedBox(height: 16),
          _RequiredLabel(AppStrings.t(context, 'av_address'), colors),
          _field(_addressController, AppStrings.t(context, 'av_address_hint'),
              Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 20),
          _RequiredLabel(AppStrings.t(context, 'av_nid_photo'), colors),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _UploadBox(
                  label: AppStrings.t(context, 'av_front'),
                  addedSuffix: AppStrings.t(context, 'av_added_suffix'),
                  image: _frontImage,
                  colors: colors,
                  onTap: () => _pickDocument(isFront: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadBox(
                  label: AppStrings.t(context, 'av_back'),
                  addedSuffix: AppStrings.t(context, 'av_added_suffix'),
                  image: _backImage,
                  colors: colors,
                  onTap: () => _pickDocument(isFront: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(AppStrings.t(context, 'av_submit')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? AppStrings.tr(context, 'field_required')
          : null,
    );
  }
}

/// A field label with a red asterisk to mark it required.
class _RequiredLabel extends StatelessWidget {
  final String text;
  final AppColors colors;
  const _RequiredLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Color(0xffDC2626))),
          ],
        ),
      ),
    );
  }
}

/// Tappable dashed-style upload placeholder that flips to a "done" state.
class _UploadBox extends StatelessWidget {
  final String label;
  final String addedSuffix;

  /// The attached photo, or null while nothing has been chosen.
  final File? image;
  final AppColors colors;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.addedSuffix,
    required this.image,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = image != null;
    final accent = uploaded ? const Color(0xff10B981) : colors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 110,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: uploaded
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(image!, fit: BoxFit.cover),
                  // Label strip so the user still knows which side this is.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xff10B981), size: 14),
                          const SizedBox(width: 4),
                          Text('$label $addedSuffix',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: accent, size: 28),
                  const SizedBox(height: 8),
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          color: accent,
                          fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
