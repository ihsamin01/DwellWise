import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

/// Lets the tenant update their profile picture, name, phone, email and
/// address. Persists via [UserProvider.updateProfile] — no backend involved.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String? _avatarUrl;
  String _originalEmail = '';
  bool _isSaving = false;

  static const _avatarPresets = [
    'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=256&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().userModel;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _avatarUrl = user?.avatarUrl;
    _originalEmail = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Change profile picture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  children: _avatarPresets.map((url) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _avatarUrl = url);
                        Navigator.of(sheetContext).pop();
                      },
                      child: CircleAvatar(radius: 32, backgroundImage: NetworkImage(url)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _avatarUrl = null);
                    Navigator.of(sheetContext).pop();
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove photo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.userModel;
    if (currentUser == null) {
      setState(() => _isSaving = false);
      return;
    }

    final emailChanged = _emailController.text.trim() != _originalEmail;

    final updated = currentUser.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      avatarUrl: _avatarUrl,
    );

    final success = await userProvider.updateProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _originalEmail = updated.email;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailChanged
                ? 'Profile updated. A verification link was sent to your new email.'
                : 'Profile updated successfully.',
          ),
          backgroundColor: const Color(0xff10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update profile. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailChanged = _emailController.text.trim() != _originalEmail && _emailController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xff0F766E).withOpacity(0.1),
                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null
                        ? const Icon(Icons.person, size: 48, color: Color(0xff0F766E))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarPicker,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Full name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Phone number is required';
                if (value.trim().length < 8) return 'Enter a valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Email address',
                prefixIcon: const Icon(Icons.email_outlined),
                helperText: emailChanged ? 'A verification link will be sent to this new address.' : null,
                helperMaxLines: 2,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email is required';
                final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
                if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
