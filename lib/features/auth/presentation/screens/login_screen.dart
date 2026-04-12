import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for successful auth
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated) {
        if (next.isOnboarded) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Back', style: AppTypography.display),
            const SizedBox(height: 8),
            Text(
              'Log in to continue your fitness journey',
              style: AppTypography.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: 40),
            AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              controller: _passwordController,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.text3,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            // Error message
            if (authState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                authState.error!,
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    ref.read(authProvider.notifier).sendPasswordReset(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent')),
                    );
                  }
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Log In',
              isLoading: authState.isLoading,
              onPressed: () {
                ref.read(authProvider.notifier).signIn(
                  _emailController.text.trim(),
                  _passwordController.text,
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with',
                    style: AppTypography.caption,
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata,
                    onPressed: () {
                      ref.read(authProvider.notifier).signInWithGoogle();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SocialButton(
                    label: 'Apple',
                    icon: Icons.apple,
                    onPressed: () {
                      ref.read(authProvider.notifier).signInWithApple();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => context.push('/register'),
                child: RichText(
                  text: TextSpan(
                    style:
                        AppTypography.body.copyWith(color: AppColors.text2),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: AppTypography.button
                            .copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),
    );
  }
}
