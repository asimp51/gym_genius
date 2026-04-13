import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';
import '../../data/b2b_repository.dart';

class BrandingSettingsScreen extends ConsumerStatefulWidget {
  const BrandingSettingsScreen({super.key});

  @override
  ConsumerState<BrandingSettingsScreen> createState() =>
      _BrandingSettingsScreenState();
}

class _BrandingSettingsScreenState
    extends ConsumerState<BrandingSettingsScreen> {
  late TextEditingController _taglineController;
  late TextEditingController _welcomeController;
  late TextEditingController _hexController;
  String _primaryHex = '3B82F6';
  String? _secondaryHex;
  bool _showPoweredBy = true;
  bool _initialized = false;

  final _presetColors = [
    'EF4444', // Red
    'F97316', // Orange
    'F59E0B', // Amber
    '10B981', // Emerald
    '14B8A6', // Teal
    '06B6D4', // Cyan
    '3B82F6', // Blue
    '6366F1', // Indigo
    '8B5CF6', // Violet
    'D946EF', // Fuchsia
    'EC4899', // Pink
    '64748B', // Slate
  ];

  @override
  void initState() {
    super.initState();
    _taglineController = TextEditingController();
    _welcomeController = TextEditingController();
    _hexController = TextEditingController();
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _welcomeController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _initFromBranding(OrganizationBranding branding) {
    if (!_initialized) {
      _primaryHex = branding.primaryColorHex;
      _secondaryHex = branding.secondaryColorHex;
      _taglineController.text = branding.tagline ?? '';
      _welcomeController.text = branding.welcomeMessage ?? '';
      _showPoweredBy = branding.showPoweredByGymGenius;
      _hexController.text = _primaryHex;
      _initialized = true;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Branding', style: AppTypography.h2),
        actions: [
          TextButton(
            onPressed: _resetToDefault,
            child: Text('Reset',
                style:
                    AppTypography.button.copyWith(color: AppColors.text3)),
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('No org'));
          _initFromBranding(org.branding);
          return _buildBody(org);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(Organization org) {
    final primaryColor = _hexToColor(_primaryHex);
    final secondaryColor =
        _secondaryHex != null ? _hexToColor(_secondaryHex!) : primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.padding2XL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Preview
          Text('Preview', style: AppTypography.h3),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  secondaryColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // Logo placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(org.name[0],
                        style: AppTypography.h1
                            .copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(org.name,
                    style: AppTypography.h2
                        .copyWith(color: primaryColor)),
                if (_taglineController.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(_taglineController.text,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center),
                ],
                if (_welcomeController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_welcomeController.text,
                      style: AppTypography.body.copyWith(fontSize: 12),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  child: Text('Start Workout',
                      style:
                          AppTypography.button.copyWith(color: Colors.white)),
                ),
                if (_showPoweredBy) ...[
                  const SizedBox(height: 16),
                  Text('Powered by GymGenius',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.text3,
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logo Upload
          Text('Logo', style: AppTypography.h3),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logo upload selected'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusCard),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                    color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined,
                      size: 32, color: AppColors.text3),
                  const SizedBox(height: 8),
                  Text('Tap to upload logo',
                      style: AppTypography.caption),
                  Text('PNG or SVG, max 2MB',
                      style: AppTypography.caption
                          .copyWith(fontSize: 10)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Primary Color
          Text('Primary Color', style: AppTypography.h3),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetColors.map((hex) {
              final selected = _primaryHex == hex;
              return InkWell(
                onTap: () {
                  setState(() {
                    _primaryHex = hex;
                    _hexController.text = hex;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(hex),
                    borderRadius: BorderRadius.circular(10),
                    border: selected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _hexToColor(hex).withValues(alpha: 0.4),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('#', style: AppTypography.body),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _hexController,
                  style: AppTypography.body,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'Custom hex code',
                    hintStyle:
                        AppTypography.body.copyWith(color: AppColors.text3),
                    filled: true,
                    fillColor: AppColors.bgSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusButton),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) {
                    if (val.length == 6) {
                      setState(() => _primaryHex = val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Secondary Color
          Text('Secondary Color', style: AppTypography.h3),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetColors.map((hex) {
              final selected = _secondaryHex == hex;
              return InkWell(
                onTap: () => setState(() => _secondaryHex = hex),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(hex),
                    borderRadius: BorderRadius.circular(10),
                    border: selected
                        ? Border.all(color: Colors.white, width: 2.5)
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _hexToColor(hex).withValues(alpha: 0.4),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Tagline
          Text('Tagline', style: AppTypography.h3),
          const SizedBox(height: 8),
          TextField(
            controller: _taglineController,
            style: AppTypography.body,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Your organization tagline',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Welcome Message
          Text('Welcome Message', style: AppTypography.h3),
          const SizedBox(height: 8),
          TextField(
            controller: _welcomeController,
            style: AppTypography.body,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Message shown to new members',
              hintStyle:
                  AppTypography.body.copyWith(color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Powered By toggle
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Show "Powered by GymGenius"',
                          style: AppTypography.body),
                      Text('Display attribution in the footer',
                          style: AppTypography.caption
                              .copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: _showPoweredBy,
                  onChanged: (val) =>
                      setState(() => _showPoweredBy = val),
                  activeThumbColor: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveBranding(org),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
              ),
              child: Text('Save Branding',
                  style: AppTypography.button
                      .copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _saveBranding(Organization org) {
    final branding = OrganizationBranding(
      logoUrl: org.branding.logoUrl,
      primaryColorHex: _primaryHex,
      secondaryColorHex: _secondaryHex,
      tagline: _taglineController.text.isNotEmpty
          ? _taglineController.text
          : null,
      welcomeMessage: _welcomeController.text.isNotEmpty
          ? _welcomeController.text
          : null,
      showPoweredByGymGenius: _showPoweredBy,
    );

    final repo = ref.read(b2bRepositoryProvider);
    repo.updateBranding(org.id, branding);
    ref.invalidate(currentOrganizationProvider);
    ref.invalidate(orgBrandingProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Branding saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _primaryHex = '3B82F6';
      _secondaryHex = null;
      _taglineController.clear();
      _welcomeController.clear();
      _showPoweredBy = true;
      _hexController.text = '3B82F6';
    });
  }
}
