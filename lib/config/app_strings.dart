import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

/// Central translation table for app chrome text — navigation labels, menu
/// items, form labels, and common buttons.
///
/// To support another language: add its code as a new top-level key in
/// [_translations] with the same key set as 'en', then add a matching
/// [AppLanguage] value.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Bottom navigation
      'home': 'Home',
      'search': 'Search',
      'saved': 'Saved',
      'messages': 'Messages',
      'profile': 'Profile',

      // Drawer / settings menu
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

      // Common buttons / words
      'save_changes': 'Save Changes',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'agree': 'I Agree',
      'call_now': 'Call Now',
      'email_us': 'Email Us',
      'get_directions': 'Get Directions',
      'delete': 'Delete',
      'next': 'Next',
      'back': 'Back',
      'optional': '(optional)',
      'yes': 'Yes',
      'no': 'No',
      'field_required': 'This field is required',

      'logout_confirm_title': 'Logout',
      'logout_confirm_message': 'Are you sure you want to logout?',

      // Language / theme screens
      'language_title': 'Language',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      'theme_title': 'Dark Mode',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System Default',

      // Profile hub
      'guest_user': 'Guest User',
      'p_acc_verif': 'Account Verification',
      'p_acc_verif_sub': 'Verify your account to get more benefits',
      'p_add_property': 'Add property',
      'p_add_property_sub': 'Add a property for rent',
      'p_my_properties': 'My properties',
      'p_my_properties_sub': 'View and manage your added properties',
      'p_purchase_history': 'Purchase history',
      'p_purchase_history_sub': 'View your purchase history',
      'p_edit_profile': 'Edit profile',
      'p_edit_profile_sub': 'Edit your profile information',
      'p_change_password': 'Change password',
      'p_change_password_sub': 'Change your login password',
      'p_logout': 'Logout',
      'p_logout_sub': 'Logout your account',
      'verif_verified': 'Verified account',
      'verif_pending': 'Verification pending',
      'verif_none': 'Not verified',

      // Account verification
      'av_info': 'Verify your identity to earn a green badge and unlock more trust from renters. A ৳500 fee applies.',
      'av_fullname': 'Full name (as per NID)',
      'av_fullname_hint': 'e.g. Isbat Samin',
      'av_nid': 'NID / Passport number',
      'av_nid_hint': 'e.g. 1990123456789',
      'av_dob': 'Date of birth',
      'av_address': 'Present address',
      'av_address_hint': 'House, road, area, city',
      'av_nid_photo': 'NID photo',
      'av_front': 'Front side',
      'av_back': 'Back side',
      'av_added_suffix': 'added',
      'av_submit': 'Pay ৳500 & Submit for verification',
      'av_attach_both': 'Please attach both sides of your NID.',
      'av_fee_title': 'Verification fee',
      'av_fee_desc': 'A one-time fee of ৳500 is paid to the admin to review and verify your account.',
      'av_amount_payable': 'Amount payable',
      'av_pay_now': 'Pay ৳500 now',
      'av_mock_payment': 'Mock payment — no real charge',
      'av_payment_received': 'Payment received. Your request is pending admin approval.',
      'av_verified_title': 'Your account is verified',
      'av_verified_desc': 'You now have the green verified badge across DwellWise.',
      'av_pending_title': 'Verification pending',
      'av_pending_desc': 'We received your details and ৳500 fee. An admin will review and approve your account shortly.',
      'av_simulate': 'Simulate admin approval',

      // Add property
      'ap_title': 'Rent your property',
      'ap_tab_basic': 'Basic',
      'ap_tab_location': 'Location',
      'ap_tab_price': 'Price',
      'ap_tab_details': 'Details',
      'ap_prop_title': 'Property title',
      'ap_prop_title_hint': 'e.g. Family flat in Mirpur DOHS',
      'ap_available': 'Available from (month)',
      'ap_select_month': 'Select month',
      'ap_type': 'Property type',
      'ap_select_type': 'Select type',
      'ap_bedrooms': 'Bedrooms',
      'ap_select_bedrooms': 'Select number of bedrooms',
      'ap_bathrooms': 'Bathrooms',
      'ap_select_bathrooms': 'Select number of bathrooms',
      'ap_balcony': 'Balcony',
      'ap_select_balcony': 'Select number of balconies',
      'ap_division': 'Division',
      'ap_select_division': 'Select division',
      'ap_district': 'District',
      'ap_select_division_first': 'Select division first',
      'ap_select_district': 'Select district',
      'ap_area': 'Area',
      'ap_select_district_first': 'Select district first',
      'ap_select_area': 'Select area',
      'ap_sector': 'Sector no',
      'ap_road': 'Road no',
      'ap_house': 'House no',
      'ap_short_address': 'Short address / House name',
      'ap_sector_hint': 'e.g. 9',
      'ap_road_hint': 'e.g. 6',
      'ap_house_hint': 'e.g. 234',
      'ap_short_address_hint': 'e.g. Green Villa',
      'ap_price': 'Price (৳)',
      'ap_price_hint': 'e.g. 25000',
      'ap_price_for': 'Price for',
      'ap_select_period': 'Select billing period',
      'ap_included': 'Price included with',
      'ap_included_desc': 'Select the utility bills bundled into the rent.',
      'ap_features': 'Features',
      'ap_description': 'Description',
      'ap_description_hint': 'Describe your property, surroundings, terms...',
      'ap_picture': 'Picture',
      'ap_photo_added': 'photo added',
      'ap_photos_added': 'photos added',
      'ap_mark_maps': 'Mark in maps',
      'ap_open_maps': 'Open exact location in Google Maps',
      'ap_map_hint': 'Fill in the location tab to preview the address',
      'ap_post': 'Post property',
      'ap_v_title': 'Please enter a property title.',
      'ap_v_basic': 'Please fill in all basic information fields.',
      'ap_v_location': 'Please select division, district and area.',
      'ap_v_price': 'Please enter a valid price.',
      'ap_posted': 'Property posted! It now appears under My properties.',
      'ap_post_failed': 'Could not post the property. Please try again.',
      'ap_maps_failed': 'Could not open Google Maps.',

      // Months
      'month_January': 'January', 'month_February': 'February', 'month_March': 'March',
      'month_April': 'April', 'month_May': 'May', 'month_June': 'June',
      'month_July': 'July', 'month_August': 'August', 'month_September': 'September',
      'month_October': 'October', 'month_November': 'November', 'month_December': 'December',

      // Property types
      'type_Family': 'Family', 'type_Bachelor': 'Bachelor', 'type_Office room': 'Office room',
      'type_Sublet': 'Sublet', 'type_Hostel': 'Hostel', 'type_Flat': 'Flat',
      'type_Apartment': 'Apartment', 'type_Studio': 'Studio', 'type_Seat Rent': 'Seat Rent',

      // Billing periods
      'period_Monthly': 'Monthly', 'period_Weekly': 'Weekly', 'period_Daily': 'Daily',

      // Bills
      'bill_Electricity bill': 'Electricity bill', 'bill_Gas bill': 'Gas bill',
      'bill_Water bill': 'Water bill', 'bill_Internet': 'Internet',
      'bill_Service charge': 'Service charge',

      // Features
      'feat_LIFT': 'LIFT', 'feat_GARAGE': 'GARAGE', 'feat_CCTV': 'CCTV', 'feat_GAS': 'GAS',

      // My properties
      'mp_owner_badge': 'Owner',
      'mp_no_phone': 'No phone added',
      'spec_bed': 'Bed', 'spec_bath': 'Bath', 'spec_balcony': 'Balcony',
      'spec_sqft': 'sqft', 'spec_from': 'From',
      'status_verified': 'Verified', 'status_pending': 'Pending',
      'mp_empty_title': 'No properties yet',
      'mp_empty_desc': 'Post your first property and it will show up here.',
      'mp_delete_title': 'Delete listing',
      'mp_delete_prefix': 'Remove',
      'mp_delete_suffix': 'from your properties?',
      'mp_removed': 'Listing removed.',

      // Purchase history
      'ph_total': 'Total rent paid',
      'ph_one_rented': 'property rented',
      'ph_many_rented': 'properties rented',
      'ph_no_rentals': 'No rentals yet',
      'ph_rented': 'Rented',
      'per_month': 'per month',
    },
    'bn': {
      // Bottom navigation
      'home': 'হোম',
      'search': 'সার্চ',
      'saved': 'সেভড',
      'messages': 'মেসেজ',
      'profile': 'প্রোফাইল',

      // Drawer / settings menu
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

      // Common buttons / words
      'save_changes': 'পরিবর্তন সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'submit': 'জমা দিন',
      'agree': 'আমি সম্মত',
      'call_now': 'কল করুন',
      'email_us': 'ইমেইল করুন',
      'get_directions': 'দিক নির্দেশনা',
      'delete': 'মুছে ফেলুন',
      'next': 'পরবর্তী',
      'back': 'পূর্ববর্তী',
      'optional': '(ঐচ্ছিক)',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'field_required': 'এই ঘরটি পূরণ করা আবশ্যক',

      'logout_confirm_title': 'লগ আউট',
      'logout_confirm_message': 'আপনি কি লগ আউট করতে নিশ্চিত?',

      // Language / theme screens
      'language_title': 'ভাষা',
      'language_english': 'English',
      'language_bangla': 'বাংলা',
      'theme_title': 'ডার্ক মোড',
      'theme_light': 'লাইট',
      'theme_dark': 'ডার্ক',
      'theme_system': 'সিস্টেম ডিফল্ট',

      // Profile hub
      'guest_user': 'গেস্ট ইউজার',
      'p_acc_verif': 'অ্যাকাউন্ট ভেরিফিকেশন',
      'p_acc_verif_sub': 'বেশি সুবিধা পেতে আপনার অ্যাকাউন্ট ভেরিফাই করুন',
      'p_add_property': 'প্রপার্টি যোগ করুন',
      'p_add_property_sub': 'ভাড়ার জন্য প্রপার্টি যোগ করুন',
      'p_my_properties': 'আমার প্রপার্টি',
      'p_my_properties_sub': 'আপনার যোগ করা প্রপার্টি দেখুন ও পরিচালনা করুন',
      'p_purchase_history': 'ক্রয়ের ইতিহাস',
      'p_purchase_history_sub': 'আপনার ক্রয়ের ইতিহাস দেখুন',
      'p_edit_profile': 'প্রোফাইল এডিট করুন',
      'p_edit_profile_sub': 'আপনার প্রোফাইলের তথ্য এডিট করুন',
      'p_change_password': 'পাসওয়ার্ড পরিবর্তন করুন',
      'p_change_password_sub': 'আপনার লগইন পাসওয়ার্ড পরিবর্তন করুন',
      'p_logout': 'লগ আউট',
      'p_logout_sub': 'আপনার অ্যাকাউন্ট থেকে লগ আউট করুন',
      'verif_verified': 'ভেরিফাইড অ্যাকাউন্ট',
      'verif_pending': 'ভেরিফিকেশন পেন্ডিং',
      'verif_none': 'ভেরিফাইড নয়',

      // Account verification
      'av_info': 'আপনার পরিচয় যাচাই করে সবুজ ব্যাজ অর্জন করুন এবং ভাড়াটেদের কাছ থেকে আরও বিশ্বাস অর্জন করুন। ৳৫০০ ফি প্রযোজ্য।',
      'av_fullname': 'পূর্ণ নাম (এনআইডি অনুযায়ী)',
      'av_fullname_hint': 'যেমন: ইসবাত সামিন',
      'av_nid': 'এনআইডি / পাসপোর্ট নম্বর',
      'av_nid_hint': 'যেমন: ১৯৯০১২৩৪৫৬৭৮৯',
      'av_dob': 'জন্ম তারিখ',
      'av_address': 'বর্তমান ঠিকানা',
      'av_address_hint': 'বাসা, রোড, এলাকা, শহর',
      'av_nid_photo': 'এনআইডি ছবি',
      'av_front': 'সামনের দিক',
      'av_back': 'পেছনের দিক',
      'av_added_suffix': 'যোগ হয়েছে',
      'av_submit': '৳৫০০ দিন এবং ভেরিফিকেশনের জন্য জমা দিন',
      'av_attach_both': 'অনুগ্রহ করে আপনার এনআইডির উভয় দিক যুক্ত করুন।',
      'av_fee_title': 'ভেরিফিকেশন ফি',
      'av_fee_desc': 'আপনার অ্যাকাউন্ট পর্যালোচনা ও যাচাই করতে অ্যাডমিনকে এককালীন ৳৫০০ ফি প্রদান করা হয়।',
      'av_amount_payable': 'প্রদেয় পরিমাণ',
      'av_pay_now': 'এখন ৳৫০০ দিন',
      'av_mock_payment': 'মক পেমেন্ট — কোনো আসল চার্জ নেই',
      'av_payment_received': 'পেমেন্ট গৃহীত হয়েছে। আপনার অনুরোধ অ্যাডমিন অনুমোদনের অপেক্ষায়।',
      'av_verified_title': 'আপনার অ্যাকাউন্ট ভেরিফাইড হয়েছে',
      'av_verified_desc': 'আপনি এখন DwellWise জুড়ে সবুজ ভেরিফাইড ব্যাজ পেয়েছেন।',
      'av_pending_title': 'ভেরিফিকেশন পেন্ডিং',
      'av_pending_desc': 'আমরা আপনার তথ্য ও ৳৫০০ ফি পেয়েছি। একজন অ্যাডমিন শীঘ্রই আপনার অ্যাকাউন্ট পর্যালোচনা ও অনুমোদন করবেন।',
      'av_simulate': 'অ্যাডমিন অনুমোদন সিমুলেট করুন',

      // Add property
      'ap_title': 'আপনার প্রপার্টি ভাড়া দিন',
      'ap_tab_basic': 'বেসিক',
      'ap_tab_location': 'লোকেশন',
      'ap_tab_price': 'মূল্য',
      'ap_tab_details': 'বিস্তারিত',
      'ap_prop_title': 'প্রপার্টির শিরোনাম',
      'ap_prop_title_hint': 'যেমন: মিরপুর ডিওএইচএস-এ ফ্যামিলি ফ্ল্যাট',
      'ap_available': 'যে মাস থেকে খালি',
      'ap_select_month': 'মাস নির্বাচন করুন',
      'ap_type': 'প্রপার্টির ধরন',
      'ap_select_type': 'ধরন নির্বাচন করুন',
      'ap_bedrooms': 'বেডরুম',
      'ap_select_bedrooms': 'বেডরুমের সংখ্যা নির্বাচন করুন',
      'ap_bathrooms': 'বাথরুম',
      'ap_select_bathrooms': 'বাথরুমের সংখ্যা নির্বাচন করুন',
      'ap_balcony': 'বারান্দা',
      'ap_select_balcony': 'বারান্দার সংখ্যা নির্বাচন করুন',
      'ap_division': 'বিভাগ',
      'ap_select_division': 'বিভাগ নির্বাচন করুন',
      'ap_district': 'জেলা',
      'ap_select_division_first': 'আগে বিভাগ নির্বাচন করুন',
      'ap_select_district': 'জেলা নির্বাচন করুন',
      'ap_area': 'এলাকা',
      'ap_select_district_first': 'আগে জেলা নির্বাচন করুন',
      'ap_select_area': 'এলাকা নির্বাচন করুন',
      'ap_sector': 'সেক্টর নম্বর',
      'ap_road': 'রোড নম্বর',
      'ap_house': 'বাসা নম্বর',
      'ap_short_address': 'সংক্ষিপ্ত ঠিকানা / বাড়ির নাম',
      'ap_sector_hint': 'যেমন: ৯',
      'ap_road_hint': 'যেমন: ৬',
      'ap_house_hint': 'যেমন: ২৩৪',
      'ap_short_address_hint': 'যেমন: গ্রিন ভিলা',
      'ap_price': 'মূল্য (৳)',
      'ap_price_hint': 'যেমন: ২৫০০০',
      'ap_price_for': 'মূল্য যে সময়ের জন্য',
      'ap_select_period': 'সময়কাল নির্বাচন করুন',
      'ap_included': 'মূল্যের সাথে অন্তর্ভুক্ত',
      'ap_included_desc': 'ভাড়ার সাথে অন্তর্ভুক্ত ইউটিলিটি বিলগুলো নির্বাচন করুন।',
      'ap_features': 'সুযোগ-সুবিধা',
      'ap_description': 'বিবরণ',
      'ap_description_hint': 'আপনার প্রপার্টি, আশপাশ ও শর্তাবলী বর্ণনা করুন...',
      'ap_picture': 'ছবি',
      'ap_photo_added': 'টি ছবি যোগ হয়েছে',
      'ap_photos_added': 'টি ছবি যোগ হয়েছে',
      'ap_mark_maps': 'ম্যাপে চিহ্নিত করুন',
      'ap_open_maps': 'গুগল ম্যাপে সঠিক অবস্থান খুলুন',
      'ap_map_hint': 'ঠিকানা প্রিভিউ দেখতে লোকেশন ট্যাব পূরণ করুন',
      'ap_post': 'প্রপার্টি পোস্ট করুন',
      'ap_v_title': 'অনুগ্রহ করে প্রপার্টির শিরোনাম লিখুন।',
      'ap_v_basic': 'অনুগ্রহ করে বেসিক তথ্যের সব ঘর পূরণ করুন।',
      'ap_v_location': 'অনুগ্রহ করে বিভাগ, জেলা ও এলাকা নির্বাচন করুন।',
      'ap_v_price': 'অনুগ্রহ করে সঠিক মূল্য লিখুন।',
      'ap_posted': 'প্রপার্টি পোস্ট হয়েছে! এটি এখন আমার প্রপার্টি-তে দেখা যাচ্ছে।',
      'ap_post_failed': 'প্রপার্টি পোস্ট করা যায়নি। আবার চেষ্টা করুন।',
      'ap_maps_failed': 'গুগল ম্যাপ খোলা যায়নি।',

      // Months
      'month_January': 'জানুয়ারি', 'month_February': 'ফেব্রুয়ারি', 'month_March': 'মার্চ',
      'month_April': 'এপ্রিল', 'month_May': 'মে', 'month_June': 'জুন',
      'month_July': 'জুলাই', 'month_August': 'আগস্ট', 'month_September': 'সেপ্টেম্বর',
      'month_October': 'অক্টোবর', 'month_November': 'নভেম্বর', 'month_December': 'ডিসেম্বর',

      // Property types
      'type_Family': 'ফ্যামিলি', 'type_Bachelor': 'ব্যাচেলর', 'type_Office room': 'অফিস রুম',
      'type_Sublet': 'সাবলেট', 'type_Hostel': 'হোস্টেল', 'type_Flat': 'ফ্ল্যাট',
      'type_Apartment': 'অ্যাপার্টমেন্ট', 'type_Studio': 'স্টুডিও', 'type_Seat Rent': 'সিট ভাড়া',

      // Billing periods
      'period_Monthly': 'মাসিক', 'period_Weekly': 'সাপ্তাহিক', 'period_Daily': 'দৈনিক',

      // Bills
      'bill_Electricity bill': 'বিদ্যুৎ বিল', 'bill_Gas bill': 'গ্যাস বিল',
      'bill_Water bill': 'পানির বিল', 'bill_Internet': 'ইন্টারনেট',
      'bill_Service charge': 'সার্ভিস চার্জ',

      // Features
      'feat_LIFT': 'লিফট', 'feat_GARAGE': 'গ্যারেজ', 'feat_CCTV': 'সিসিটিভি', 'feat_GAS': 'গ্যাস',

      // My properties
      'mp_owner_badge': 'মালিক',
      'mp_no_phone': 'ফোন নম্বর যোগ করা হয়নি',
      'spec_bed': 'বেড', 'spec_bath': 'বাথ', 'spec_balcony': 'বারান্দা',
      'spec_sqft': 'বর্গফুট', 'spec_from': 'থেকে',
      'status_verified': 'ভেরিফাইড', 'status_pending': 'পেন্ডিং',
      'mp_empty_title': 'এখনো কোনো প্রপার্টি নেই',
      'mp_empty_desc': 'আপনার প্রথম প্রপার্টি পোস্ট করুন, এটি এখানে দেখা যাবে।',
      'mp_delete_title': 'লিস্টিং মুছুন',
      'mp_delete_prefix': 'আপনার প্রপার্টি থেকে',
      'mp_delete_suffix': 'সরিয়ে ফেলবেন?',
      'mp_removed': 'লিস্টিং সরিয়ে ফেলা হয়েছে।',

      // Purchase history
      'ph_total': 'মোট প্রদত্ত ভাড়া',
      'ph_one_rented': 'টি প্রপার্টি ভাড়া নেওয়া হয়েছে',
      'ph_many_rented': 'টি প্রপার্টি ভাড়া নেওয়া হয়েছে',
      'ph_no_rentals': 'এখনো কোনো ভাড়া নেই',
      'ph_rented': 'ভাড়া নেওয়া হয়েছে',
      'per_month': 'প্রতি মাসে',
    },
  };

  /// Looks up [key] in the currently selected language, rebuilding the
  /// caller whenever the language changes. Falls back to English, then to
  /// the raw key if nothing matches.
  static String t(BuildContext context, String key) {
    final code = context.watch<LocaleProvider>().languageCode;
    return _translations[code]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// Non-reactive lookup for use outside build (e.g. inside callbacks). Reads
  /// the current language without subscribing to changes.
  static String tr(BuildContext context, String key) {
    final code = context.read<LocaleProvider>().languageCode;
    return _translations[code]?[key] ?? _translations['en']?[key] ?? key;
  }

  /// True when the app is currently showing Bangla.
  static bool isBangla(BuildContext context) =>
      context.watch<LocaleProvider>().languageCode == 'bn';

  /// Converts ASCII digits in [input] to Bangla digits (used for prices/counts
  /// so numbers read naturally in Bangla).
  static String digits(BuildContext context, String input) {
    if (context.read<LocaleProvider>().languageCode != 'bn') return input;
    return toBanglaDigits(input);
  }

  static String toBanglaDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var out = input;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], bn[i]);
    }
    return out;
  }
}
