import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/l10n/locale_provider.dart';
import '../providers/settings_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/user_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final user = ref.watch(currentUserProvider);

    final isMetric = settings.weightUnit == 'kg';
    final isDarkMode = settings.theme == 'dark';
    final restTimer = settings.restTimerSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(context, ref, settings, settingsNotifier, user,
          isMetric, isDarkMode, restTimer),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Language'),
        backgroundColor: AppColors.bgSecondary,
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('\u{1F1FA}\u{1F1F8}  ', style: TextStyle(fontSize: 22)),
                Text('English',
                    style: AppTypography.body.copyWith(
                      fontWeight: currentLocale.languageCode == 'en'
                          ? FontWeight.w700
                          : FontWeight.w400,
                    )),
                if (currentLocale.languageCode == 'en')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, color: AppColors.accent, size: 20),
                  ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                const Text('\u{1F1F8}\u{1F1E6}  ', style: TextStyle(fontSize: 22)),
                Text('\u0627\u0644\u0639\u0631\u0628\u064A\u0629 (Arabic)',
                    style: AppTypography.body.copyWith(
                      fontWeight: currentLocale.languageCode == 'ar'
                          ? FontWeight.w700
                          : FontWeight.w400,
                    )),
                if (currentLocale.languageCode == 'ar')
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.check, color: AppColors.accent, size: 20),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    UserSettings settings,
    SettingsNotifier settingsNotifier,
    dynamic user,
    bool isMetric,
    bool isDarkMode,
    int restTimer,
  ) {
    return ListView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        children: [
          // Account
          _SectionTitle('Account'),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => context.push('/edit-profile'),
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Change Email',
              subtitle: user?.email ?? '',
              onTap: () => context.push('/change-email'),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => context.push('/change-password'),
            ),
          ]),
          const SizedBox(height: 24),

          // Preferences
          _SectionTitle('Preferences'),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _SettingsSwitch(
              icon: Icons.straighten,
              title: 'Metric Units',
              subtitle: isMetric ? 'kg, cm' : 'lbs, in',
              value: isMetric,
              onChanged: (v) {
                settingsNotifier.updateWeightUnit(v ? 'kg' : 'lb');
                settingsNotifier.updateDistanceUnit(v ? 'km' : 'mi');
                settingsNotifier.updateMeasurementUnit(v ? 'cm' : 'in');
              },
            ),
            _SettingsSwitch(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: isDarkMode,
              onChanged: (v) {
                settingsNotifier.updateTheme(v ? 'dark' : 'light');
              },
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: ref.watch(localeProvider).languageCode == 'ar'
                  ? '\u0627\u0644\u0639\u0631\u0628\u064A\u0629'
                  : 'English',
              onTap: () => _showLanguageDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.timer_outlined,
              title: 'Default Rest Timer',
              subtitle: '${restTimer}s',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        size: 20, color: AppColors.text3),
                    onPressed: () {
                      if (restTimer > 30) {
                        settingsNotifier.updateRestTimer(restTimer - 15);
                      }
                    },
                  ),
                  Text('${restTimer}s',
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        size: 20, color: AppColors.accent),
                    onPressed: () {
                      if (restTimer < 300) {
                        settingsNotifier.updateRestTimer(restTimer + 15);
                      }
                    },
                  ),
                ],
              ),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // Notifications
          _SectionTitle('Notifications'),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _SettingsSwitch(
              icon: Icons.notifications_outlined,
              title: 'Workout Reminders',
              value: settings.notifications.workoutReminders,
              onChanged: (v) => settingsNotifier.toggleWorkoutReminders(v),
            ),
            _SettingsSwitch(
              icon: Icons.trending_up,
              title: 'Streak Reminders',
              value: settings.notifications.streakReminders,
              onChanged: (v) => settingsNotifier.toggleStreakReminders(v),
            ),
            _SettingsSwitch(
              icon: Icons.people_outline,
              title: 'Social Notifications',
              value: settings.notifications.socialActivity,
              onChanged: (v) => settingsNotifier.toggleSocialActivity(v),
            ),
            _SettingsSwitch(
              icon: Icons.smart_toy_outlined,
              title: 'AI Recommendations',
              value: settings.notifications.aiRecommendations,
              onChanged: (v) => settingsNotifier.toggleAiRecommendations(v),
            ),
          ]),
          const SizedBox(height: 24),

          // Connected Apps
          _SectionTitle('Connected Apps'),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.watch_outlined,
              title: 'Wearables & Health',
              subtitle: 'Apple Health, Health Connect, Smartwatch',
              onTap: () => context.push('/connected-devices'),
            ),
            _SettingsTile(
              icon: Icons.bluetooth,
              title: 'Bluetooth Devices',
              trailing: _ConnectButton(connected: false),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),

          // About
          _SectionTitle('About'),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0 (Build 1)',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),
        ],
      );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTypography.caption
            .copyWith(fontSize: 13, fontWeight: FontWeight.w600));
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i < children.length - 1)
                const Divider(
                    height: 1, color: AppColors.border, indent: 52),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.text2),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTypography.caption.copyWith(fontSize: 11)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.text3),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.text2),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                if (subtitle != null)
                  Text(subtitle!,
                      style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final bool connected;
  const _ConnectButton({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: connected
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: connected
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Text(
        connected ? 'Connected' : 'Connect',
        style: AppTypography.caption.copyWith(
          color: connected ? AppColors.success : AppColors.text2,
          fontSize: 11,
        ),
      ),
    );
  }
}
