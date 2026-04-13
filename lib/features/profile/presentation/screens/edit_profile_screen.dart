import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _photoUrlCtrl;
  DateTime? _birthDate;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _photoUrlCtrl = TextEditingController(text: user?.photoUrl ?? '');
    _birthDate = user?.birthDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).updateProfile(
            displayName: name,
            photoUrl: _photoUrlCtrl.text.trim().isEmpty
                ? null
                : _photoUrlCtrl.text.trim(),
            birthDate: _birthDate,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    child: Text(
                      _nameCtrl.text.isNotEmpty
                          ? _nameCtrl.text[0].toUpperCase()
                          : '?',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.accent,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 8),

            AppTextField(
              controller: _nameCtrl,
              label: 'Display Name',
              hint: 'Your name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _photoUrlCtrl,
              label: 'Photo URL',
              hint: 'https://...',
              prefixIcon: Icons.image_outlined,
            ),
            const SizedBox(height: 16),

            // Birth date picker
            Text('Birth Date', style: AppTypography.caption),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(1995, 1, 1),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _birthDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined,
                        color: AppColors.text2, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate != null
                          ? '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}'
                          : 'Select birth date',
                      style: AppTypography.body.copyWith(
                        color: _birthDate != null
                            ? AppColors.text1
                            : AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (_error != null) ...[
              Text(_error!,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.error)),
              const SizedBox(height: 16),
            ],

            AppButton(
              label: 'Save Changes',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
