import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }

  void setEnglish() => state = const Locale('en');
  void setArabic() => state = const Locale('ar');

  bool get isArabic => state.languageCode == 'ar';
  bool get isRTL => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final isRTLProvider = Provider<bool>((ref) {
  return ref.watch(localeProvider).languageCode == 'ar';
});
