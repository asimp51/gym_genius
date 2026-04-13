import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Password is required to confirm this change');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });

    try {
      await ref.read(authProvider.notifier).updateEmail(email, password);
      setState(() => _success = 'Email updated successfully');
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
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
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
            Text('Current Email', style: AppTypography.caption),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: AppTypography.body),
            const SizedBox(height: 24),

            AppTextField(
              controller: _emailCtrl,
              label: 'New Email',
              hint: 'Enter new email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _passwordCtrl,
              label: 'Confirm Password',
              hint: 'Enter your current password',
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
              label: 'Update Email',
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
