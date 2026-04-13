import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text;
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty) {
      setState(() => _error = 'Current password is required');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });

    try {
      await ref.read(authProvider.notifier).updatePassword(current, newPass);
      setState(() => _success = 'Password updated successfully');
      await Future.delayed(const Duration(seconds: 1));
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
        title: const Text('Change Password'),
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
            AppTextField(
              controller: _currentCtrl,
              label: 'Current Password',
              hint: 'Enter current password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _newCtrl,
              label: 'New Password',
              hint: 'At least 6 characters',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _confirmCtrl,
              label: 'Confirm New Password',
              hint: 'Re-enter new password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 24),

            if (_error != null) ...[
              Text(_error!,
                  style:
                      AppTypography.caption.copyWith(color: AppColors.error)),
              const SizedBox(height: 16),
            ],

            if (_success != null) ...[
              Text(_success!,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.success)),
              const SizedBox(height: 16),
            ],

            AppButton(
              label: 'Update Password',
              isFullWidth: true,
              isLoading: _isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
