import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/exercises/presentation/screens/exercise_library_screen.dart';
import '../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../features/workouts/presentation/screens/workout_templates_screen.dart';
import '../features/workouts/presentation/screens/template_detail_screen.dart';
import '../features/workouts/presentation/screens/active_workout_screen.dart';
import '../features/workouts/presentation/screens/workout_summary_screen.dart';
import '../features/progress/presentation/screens/progress_dashboard_screen.dart';
import '../features/progress/presentation/screens/strength_progress_screen.dart';
import '../features/progress/presentation/screens/body_stats_screen.dart';
import '../features/ai_trainer/presentation/screens/ai_chat_screen.dart';
import '../features/social/presentation/screens/social_feed_screen.dart';
import '../features/social/presentation/screens/leaderboard_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../features/gamification/presentation/screens/achievements_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/subscription_screen.dart';
import '../features/settings/presentation/screens/change_email_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/workouts/presentation/screens/template_editor_screen.dart';
import '../features/workouts/domain/workout_template_model.dart';
import '../features/wearables/presentation/screens/connected_devices_screen.dart';
import '../features/meal_planner/presentation/screens/meal_planner_dashboard_screen.dart';
import '../features/meal_planner/presentation/screens/ai_meal_generator_screen.dart';
import '../features/meal_planner/presentation/screens/ai_plan_review_screen.dart';
import '../features/meal_planner/presentation/screens/recipe_library_screen.dart';
import '../features/meal_planner/presentation/screens/recipe_detail_screen.dart';
import '../features/meal_planner/presentation/screens/weekly_meal_calendar_screen.dart';
import '../features/meal_planner/presentation/screens/grocery_list_screen.dart';
import '../features/meal_planner/presentation/screens/meal_prep_screen.dart';
import '../features/b2b/presentation/screens/admin_dashboard_screen.dart';
import '../features/b2b/presentation/screens/member_management_screen.dart';
import '../features/b2b/presentation/screens/program_builder_screen.dart';
import '../features/b2b/presentation/screens/trainer_dashboard_screen.dart';
import '../features/b2b/presentation/screens/org_analytics_screen.dart';
import '../features/b2b/presentation/screens/branding_settings_screen.dart';
import '../features/b2b/presentation/screens/org_settings_screen.dart';
import '../features/b2b/presentation/screens/b2b_onboarding_screen.dart';
import '../features/b2b/presentation/screens/b2b_join_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorExercisesKey =
    GlobalKey<NavigatorState>(debugLabel: 'exercises');
final _shellNavigatorWorkoutKey =
    GlobalKey<NavigatorState>(debugLabel: 'workout');
final _shellNavigatorProgressKey =
    GlobalKey<NavigatorState>(debugLabel: 'progress');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

// Simple auth flag for now
bool isAuthenticated = false;
bool isB2BUser = false;
String? b2bRole;

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final path = state.uri.path;
    // Allow B2B routes for all users (auth checked at screen level)
    if (path == '/b2b-join' || path == '/b2b-onboarding') {
      return null;
    }
    // If authenticated B2B admin tries to go to /home, redirect to admin dashboard
    if (isAuthenticated && isB2BUser && b2bRole == 'admin' && path == '/home') {
      return '/b2b-admin';
    }
    // If authenticated B2B trainer tries to go to /home, redirect to trainer dashboard
    if (isAuthenticated && isB2BUser && b2bRole == 'trainer' && path == '/home') {
      return '/b2b-trainer';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Active workout (full-screen, no nav bar)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/active-workout',
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/workout-summary',
      builder: (context, state) => const WorkoutSummaryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/ai-chat',
      builder: (context, state) => const AiChatScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/social-feed',
      builder: (context, state) => const SocialFeedScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/nutrition',
      builder: (context, state) => const NutritionScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/change-email',
      builder: (context, state) => const ChangeEmailScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/template-editor',
      builder: (context, state) => TemplateEditorScreen(
        template: state.extra as WorkoutTemplateModel?,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/strength-progress',
      builder: (context, state) => const StrengthProgressScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/body-stats',
      builder: (context, state) => const BodyStatsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/exercise-detail',
      builder: (context, state) => ExerciseDetailScreen(
        exerciseId: state.extra as String?,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/template-detail',
      builder: (context, state) => const TemplateDetailScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/connected-devices',
      builder: (context, state) => const ConnectedDevicesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/meal-planner',
      builder: (context, state) => const MealPlannerDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/ai-meal-generator',
      builder: (context, state) => const AiMealGeneratorScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/ai-plan-review',
      builder: (context, state) => const AiPlanReviewScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recipe-library',
      builder: (context, state) => const RecipeLibraryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recipe-detail/:id',
      builder: (context, state) => RecipeDetailScreen(
        recipeId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/weekly-meal-calendar',
      builder: (context, state) => const WeeklyMealCalendarScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/grocery-list',
      builder: (context, state) => const GroceryListScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/meal-prep',
      builder: (context, state) => const MealPrepScreen(),
    ),
    // B2B Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-members',
      builder: (context, state) => const MemberManagementScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-program-builder',
      builder: (context, state) => const ProgramBuilderScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-trainer',
      builder: (context, state) => const TrainerDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-analytics',
      builder: (context, state) => const OrgAnalyticsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-branding',
      builder: (context, state) => const BrandingSettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-settings',
      builder: (context, state) => const OrgSettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-onboarding',
      builder: (context, state) => const B2bOnboardingScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/b2b-join',
      builder: (context, state) => const B2bJoinScreen(),
    ),
    // Main app shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorExercisesKey,
          routes: [
            GoRoute(
              path: '/exercises',
              builder: (context, state) => const ExerciseLibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorWorkoutKey,
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (context, state) => const WorkoutTemplatesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProgressKey,
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
