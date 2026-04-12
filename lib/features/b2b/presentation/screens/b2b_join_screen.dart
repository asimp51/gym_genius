import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../../data/b2b_repository.dart';
import '../providers/b2b_providers.dart';

class B2bJoinScreen extends ConsumerStatefulWidget {
  const B2bJoinScreen({super.key});

  @override
  ConsumerState<B2bJoinScreen> createState() => _B2bJoinScreenState();
}

class _B2bJoinScreenState extends ConsumerState<B2bJoinScreen> {
  final _codeController = TextEditingController();
  Organization? _foundOrg;
  bool _isSearching = false;
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.group_add,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            Text('Join Your Organization',
                style: AppTypography.h1, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Enter the invite code from your gym, company, or trainer to get started.',
              style: AppTypography.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Code input
            TextField(
              controller: _codeController,
              style: AppTypography.stat.copyWith(
                  fontSize: 24, letterSpacing: 6),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              onChanged: (val) {
                if (_error != null) setState(() => _error = null);
                if (_foundOrg != null) setState(() => _foundOrg = null);
                if (val.length == 6) _lookupCode(val);
              },
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: AppTypography.stat.copyWith(
                    fontSize: 24,
                    color: AppColors.text3,
                    letterSpacing: 6),
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            const SizedBox(height: 12),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                    border:
                        Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: AppTypography.body.copyWith(
                                  color: AppColors.error,
                                  fontSize: 13))),
                    ],
                  ),
                ),
              ),

            // Found org card
            if (_foundOrg != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _hexToColor(
                                _foundOrg!.branding.primaryColorHex),
                            _hexToColor(
                                _foundOrg!.branding.secondaryColorHex ??
                                    _foundOrg!.branding.primaryColorHex),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(_foundOrg!.name[0],
                            style: AppTypography.h2
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_foundOrg!.name, style: AppTypography.h2),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _foundOrg!.type[0].toUpperCase() +
                            _foundOrg!.type.substring(1),
                        style: AppTypography.caption.copyWith(
                            color: AppColors.success, fontSize: 11),
                      ),
                    ),
                    if (_foundOrg!.branding.tagline != null) ...[
                      const SizedBox(height: 8),
                      Text(_foundOrg!.branding.tagline!,
                          style: AppTypography.caption,
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${_foundOrg!.memberIds.length} members',
                      style: AppTypography.caption
                          .copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isJoining ? null : _joinOrg,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusButton),
                          ),
                          disabledBackgroundColor:
                              AppColors.success.withOpacity(0.5),
                        ),
                        child: _isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Join ${_foundOrg!.name}',
                                style: AppTypography.button
                                    .copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // QR Code option
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('QR scanner opened'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner,
                        color: AppColors.accent, size: 24),
                    const SizedBox(width: 12),
                    Text('Scan QR Code',
                        style: AppTypography.body
                            .copyWith(color: AppColors.accent)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Or create
            TextButton(
              onPressed: () => context.push('/b2b-onboarding'),
              child: Text('Or create your own organization',
                  style: AppTypography.body.copyWith(
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.accent,
                  )),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _lookupCode(String code) async {
    setState(() {
      _isSearching = true;
      _error = null;
      _foundOrg = null;
    });

    final repo = ref.read(b2bRepositoryProvider);
    final org = await repo.findByAccessCode(code);

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (org != null) {
          _foundOrg = org;
        } else {
          _error = 'No organization found with code "$code"';
        }
      });
    }
  }

  void _joinOrg() async {
    if (_foundOrg == null) return;
    setState(() => _isJoining = true);

    final repo = ref.read(b2bRepositoryProvider);
    await repo.joinOrganization(
      _foundOrg!.id,
      'current_user',
      'New Member',
    );

    ref.invalidate(currentOrganizationProvider);
    ref.invalidate(isB2BUserProvider);
    ref.invalidate(currentB2BRoleProvider);

    if (mounted) {
      setState(() => _isJoining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to ${_foundOrg!.name}!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
