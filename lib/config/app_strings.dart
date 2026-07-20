import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

/// Central translation table for app chrome text — navigation labels, menu
/// items, and common buttons. User-generated content (names, listings,
/// addresses) is intentionally never looked up here.
///
/// To support another language: add its code as a new top-level key in
/// [_translations] with the same key set as 'en', then add a matching
/// [AppLanguage] value.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'home': 'Home',
      'search': 'Search',
      'saved': 'Saved',
      'messages': 'Messages',
      'profile': 'Profile',
      'menu_edit_profile': 'Edit Profile',
      'menu_change_password': 'Change Password',
      'menu_account_security': 'Account & Security',
      'menu_notifications': 'Notification Settings',
      'menu_language': 'Language',
      'menu_dark_mode': 'Dark Mode',
      'menu_terms': 'Terms & Conditions',
      'menu_privacy': 'Privacy Policy',
      'menu_help': 'Help & Support',
      'menu_contact': 'Contact Us',
      'menu_rate': 'Rate the App',
      'menu_logout': 'Logout',
      'save_changes': 'Save Changes',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'agree': 'I Agree',
      'call_now': 'Call Now',
      'email_us': 'Email Us',
      'get_directions': 'Get Directions',
      'delete': 'Delete',
      'logout_confirm_title': 'Logout',
      'logout_confirm_message': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',
      'language_title': 'Language',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      'theme_title': 'Dark Mode',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System Default',
    },
    'bn': {
      'home': 'হোম',
      'search': 'সার্চ',
      'saved': 'সেভড',
      'messages': 'মেসেজ',
      'profile': 'প্রোফাইল',
      'menu_edit_profile': 'প্রোফাইল এডিট করুন',
      'menu_change_password': 'পাসওয়ার্ড পরিবর্তন করুন',
      'menu_account_security': 'অ্যাকাউন্ট ও সিকিউরিটি',
      'menu_notifications': 'নোটিফিকেশন সেটিংস',
      'menu_language': 'ভাষা',
      'menu_dark_mode': 'ডার্ক মোড',
      'menu_terms': 'শর্তাবলী',
      'menu_privacy': 'গোপনীয়তা নীতি',
      'menu_help': 'সহায়তা কেন্দ্র',
      'menu_contact': 'যোগাযোগ করুন',
      'menu_rate': 'অ্যাপ রেট করুন',
      'menu_logout': 'লগ আউট',
      'save_changes': 'পরিবর্তন সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'submit': 'জমা দিন',
      'agree': 'আমি সম্মত',
      'call_now': 'কল করুন',
      'email_us': 'ইমেইল করুন',
      'get_directions': 'দিক নির্দেশনা',
      'delete': 'মুছে ফেলুন',
      'logout_confirm_title': 'লগ আউট',
      'logout_confirm_message': 'আপনি কি লগ আউট করতে নিশ্চিত?',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'language_title': 'ভাষা',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      'theme_title': 'ডার্ক মোড',
      'theme_light': 'লাইট',
      'theme_dark': 'ডার্ক',
      'theme_system': 'সিস্টেম ডিফল্ট',
    },
  };

  /// Looks up [key] in the currently selected language, rebuilding the
  /// caller whenever the language changes. Falls back to English, then to
  /// the raw key if nothing matches.
  static String t(BuildContext context, String key) {
    final code = context.watch<LocaleProvider>().languageCode;
    return _translations[code]?[key] ?? _translations['en']?[key] ?? key;
  }
}
