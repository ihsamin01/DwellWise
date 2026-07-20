import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

/// Account verification: the user submits identity details and pays a mock
/// ৳500 fee, moving the account to "Pending admin approval". Once an admin
/// approves it (mock), the account earns a green verified badge.
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

  bool _frontUploaded = false;
  bool _backUploaded = false;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_frontUploaded || !_backUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'av_attach_both'))),
      );
      return;
    }

    final confirmed = await _showPaymentSheet();
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final ok = await context.read<UserProvider>().submitVerification();
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'av_payment_received')),
          backgroundColor: const Color(0xff10B981),
        ),
      );
    }
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
                    Text('৳${AppStrings.digits(sheetContext, '500')}',
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
      // SafeArea keeps the submit button clear of the device's bottom
      // navigation bar (gesture bar or 3-button bar) on every device.
      body: SafeArea(
        child: status == VerificationStatus.unverified
            ? _buildForm(colors)
            : _buildStatusView(colors, status),
      ),
    );
  }

  Widget _buildStatusView(AppColors colors, VerificationStatus status) {
    final verified = status == VerificationStatus.verified;
    final color = verified ? const Color(0xff10B981) : const Color(0xffF59E0B);
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
            // Demo helper so the green badge can be shown without a real admin.
            if (!verified) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.read<UserProvider>().approveVerification(),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: Text(AppStrings.t(context, 'av_simulate')),
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
                  uploaded: _frontUploaded,
                  colors: colors,
                  onTap: () => setState(() => _frontUploaded = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadBox(
                  label: AppStrings.t(context, 'av_back'),
                  addedSuffix: AppStrings.t(context, 'av_added_suffix'),
                  uploaded: _backUploaded,
                  colors: colors,
                  onTap: () => setState(() => _backUploaded = true),
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
  final bool uploaded;
  final AppColors colors;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.addedSuffix,
    required this.uploaded,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = uploaded ? const Color(0xff10B981) : colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(uploaded ? Icons.check_circle : Icons.add_a_photo_outlined,
                color: accent, size: 28),
            const SizedBox(height: 8),
            Text(uploaded ? '$label $addedSuffix' : label,
                style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
