import 'package:flutter/material.dart';
import 'translations_en.dart';
import 'translations_ar.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': translationsEn,
    'ar': translationsAr,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // Auth
  String get appName => get('app_name');
  String get tagline => get('tagline');
  String get getStarted => get('get_started');
  String get login => get('login');
  String get register => get('register');
  String get welcomeBack => get('welcome_back');
  String get createAccount => get('create_account');
  String get email => get('email');
  String get password => get('password');
  String get confirmPassword => get('confirm_password');
  String get fullName => get('full_name');
  String get forgotPassword => get('forgot_password');
  String get resetPassword => get('reset_password');
  String get sendResetLink => get('send_reset_link');
  String get orContinueWith => get('or_continue_with');
  String get dontHaveAccount => get('dont_have_account');
  String get alreadyHaveAccount => get('already_have_account');
  String get signUp => get('sign_up');
  String get logIn => get('log_in');
  String get logOut => get('log_out');
  String get joinOrganization => get('join_organization');
  String get forBusiness => get('for_business');

  // Onboarding
  String get whatAreYourGoals => get('what_are_your_goals');
  String get selectAllThatApply => get('select_all_that_apply');
  String get buildMuscle => get('build_muscle');
  String get loseWeight => get('lose_weight');
  String get getStronger => get('get_stronger');
  String get improveEndurance => get('improve_endurance');
  String get stayFlexible => get('stay_flexible');
  String get generalHealth => get('general_health');
  String get experienceLevel => get('experience_level');
  String get beginner => get('beginner');
  String get intermediate => get('intermediate');
  String get advanced => get('advanced');
  String get whatEquipment => get('what_equipment');
  String get howManyDays => get('how_many_days');
  String get whichDays => get('which_days');
  String get continueText => get('continue_text');
  String get finishSetup => get('finish_setup');
  String get stepOf => get('step_of');

  // Bottom Nav
  String get home => get('home');
  String get exercises => get('exercises');
  String get workout => get('workout');
  String get progress => get('progress');
  String get profile => get('profile');

  // Home
  String get goodMorning => get('good_morning');
  String get goodAfternoon => get('good_afternoon');
  String get goodEvening => get('good_evening');
  String get todaysWorkout => get('todays_workout');
  String get startWorkout => get('start_workout');
  String get thisWeek => get('this_week');
  String get workouts => get('workouts');
  String get volume => get('volume');
  String get prs => get('prs');
  String get recentActivity => get('recent_activity');
  String get aiRecommendations => get('ai_recommendations');
  String get chatWithAi => get('chat_with_ai');
  String get dayStreak => get('day_streak');
  String get level => get('level');
  String get aiCredits => get('ai_credits');

  // Exercises
  String get searchExercises => get('search_exercises');
  String get all => get('all');
  String get chest => get('chest');
  String get back => get('back');
  String get shoulders => get('shoulders');
  String get arms => get('arms');
  String get legs => get('legs');
  String get core => get('core');
  String get cardio => get('cardio');
  String get instructions => get('instructions');
  String get history => get('history');
  String get records => get('records');
  String get primaryMuscles => get('primary_muscles');
  String get secondaryMuscles => get('secondary_muscles');
  String get equipment => get('equipment');
  String get difficulty => get('difficulty');
  String get exerciseLibrary => get('exercise_library');

  // Workouts
  String get myWorkouts => get('my_workouts');
  String get createNew => get('create_new');
  String get startEmpty => get('start_empty');
  String get myTemplates => get('my_templates');
  String get recommended => get('recommended');
  String get exercisesCount => get('exercises_count');
  String get minutes => get('minutes');
  String get sets => get('sets');
  String get reps => get('reps');
  String get weight => get('weight');
  String get rest => get('rest');
  String get warmup => get('warmup');
  String get finish => get('finish');
  String get addExercise => get('add_exercise');
  String get addSet => get('add_set');
  String get restTimer => get('rest_timer');
  String get skip => get('skip');
  String get workoutComplete => get('workout_complete');
  String get totalVolume => get('total_volume');
  String get totalSets => get('total_sets');
  String get duration => get('duration');
  String get personalRecords => get('personal_records');
  String get newPR => get('new_pr');
  String get shareWorkout => get('share_workout');
  String get done => get('done');
  String get repeatWorkout => get('repeat_workout');
  String get workoutHistory => get('workout_history');

  // Progress
  String get overview => get('overview');
  String get strength => get('strength');
  String get body => get('body');
  String get photos => get('photos');
  String get weeklyVolume => get('weekly_volume');
  String get workoutFrequency => get('workout_frequency');
  String get bodyWeight => get('body_weight');
  String get bodyFat => get('body_fat');
  String get measurements => get('measurements');
  String get logMeasurements => get('log_measurements');
  String get addPhoto => get('add_photo');
  String get compare => get('compare');
  String get estimated1RM => get('estimated_1rm');
  String get bestWeight => get('best_weight');
  String get bestVolume => get('best_volume');
  String get thisMonth => get('this_month');

  // AI
  String get aiTrainer => get('ai_trainer');
  String get gymGeniusAi => get('gym_genius_ai');
  String get typeMessage => get('type_message');
  String get aiCreditsUsed => get('ai_credits_used');
  String get upgradeForMore => get('upgrade_for_more');
  String get watchAdForCredit => get('watch_ad_for_credit');

  // Social
  String get community => get('community');
  String get leaderboard => get('leaderboard');
  String get streaks => get('streaks');
  String get xp => get('xp');
  String get like => get('like');
  String get comment => get('comment');
  String get share => get('share');

  // Nutrition
  String get nutrition => get('nutrition');
  String get calories => get('calories');
  String get protein => get('protein');
  String get carbs => get('carbs');
  String get fat => get('fat');
  String get breakfast => get('breakfast');
  String get lunch => get('lunch');
  String get dinner => get('dinner');
  String get snack => get('snack');
  String get addMeal => get('add_meal');
  String get tryMealPlanner => get('try_meal_planner');

  // Meal Planner
  String get mealPlanner => get('meal_planner');
  String get aiMealGenerator => get('ai_meal_generator');
  String get generatePlan => get('generate_plan');
  String get browseRecipes => get('browse_recipes');
  String get groceryList => get('grocery_list');
  String get mealPrep => get('meal_prep');
  String get recipes => get('recipes');
  String get savePlan => get('save_plan');
  String get weeklyCalendar => get('weekly_calendar');
  String get addToPlan => get('add_to_plan');
  String get toGrocery => get('to_grocery');
  String get servings => get('servings');
  String get prepTime => get('prep_time');
  String get cookTime => get('cook_time');
  String get ingredients => get('ingredients');
  String get tips => get('tips');

  // Gamification
  String get achievements => get('achievements');
  String get badges => get('badges');
  String get earned => get('earned');
  String get locked => get('locked');
  String get xpEarned => get('xp_earned');
  String get levelUp => get('level_up');

  // Profile & Settings
  String get editProfile => get('edit_profile');
  String get settings => get('settings');
  String get subscription => get('subscription');
  String get account => get('account');
  String get preferences => get('preferences');
  String get notifications => get('notifications');
  String get connectedApps => get('connected_apps');
  String get about => get('about');
  String get units => get('units');
  String get theme => get('theme');
  String get dark => get('dark');
  String get light => get('light');
  String get system => get('system');
  String get language => get('language');
  String get restTimerDefault => get('rest_timer_default');
  String get workoutReminders => get('workout_reminders');
  String get streakAlerts => get('streak_alerts');
  String get aiInsights => get('ai_insights');
  String get socialActivityNotif => get('social_activity_notif');
  String get version => get('version');
  String get termsOfService => get('terms_of_service');
  String get privacyPolicy => get('privacy_policy');
  String get support => get('support');

  // Subscription
  String get free => get('free_tier');
  String get premium => get('premium');
  String get premiumMonthly => get('premium_monthly');
  String get premiumAnnual => get('premium_annual');
  String get bestValue => get('best_value');
  String get save33 => get('save_33');
  String get startFreeTrial => get('start_free_trial');
  String get restorePurchase => get('restore_purchase');
  String get perMonth => get('per_month');
  String get perYear => get('per_year');
  String get upgradeToPremium => get('upgrade_to_premium');

  // B2B
  String get forBusinessTitle => get('for_business_title');
  String get starter => get('starter_plan');
  String get professional => get('professional_plan');
  String get enterprise => get('enterprise_plan');
  String get perMember => get('per_member');
  String get startTrial30 => get('start_trial_30');
  String get adminDashboard => get('admin_dashboard');
  String get members => get('members');
  String get trainers => get('trainers');
  String get programs => get('programs');
  String get analytics => get('analytics');
  String get branding => get('branding');
  String get inviteCode => get('invite_code');
  String get joinOrg => get('join_org');
  String get myClients => get('my_clients');

  // Common
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get search => get('search');
  String get filter => get('filter');
  String get sortBy => get('sort_by');
  String get noData => get('no_data');
  String get loading => get('loading');
  String get error => get('error');
  String get retry => get('retry');
  String get success => get('success');
  String get confirm => get('confirm');
  String get yes => get('yes');
  String get no => get('no');
  String get ok => get('ok');
  String get close => get('close');
  String get seeAll => get('see_all');
  String get today => get('today');
  String get yesterday => get('yesterday');
  String get daysAgo => get('days_ago');
  String get kg => get('kg');
  String get lb => get('lb');
  String get min => get('min');
  String get sec => get('sec');
  String get hr => get('hr');
  String get cm => get('cm');
  String get inch => get('inch');

  // Language selector
  String get english => get('english');
  String get arabic => get('arabic');
  String get selectLanguage => get('select_language');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
