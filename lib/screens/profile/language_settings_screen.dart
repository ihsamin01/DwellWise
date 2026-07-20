import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../providers/locale_provider.dart';

/// Lets the user switch the app's display language between English and
/// Bangla. Only app chrome (labels, menus, buttons) is translated — user
/// content such as names, listings, and addresses is left untouched.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'language_title'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                RadioListTile<AppLanguage>(
                  title: Text(AppStrings.t(context, 'language_english')),
                  subtitle: const Text('English'),
                  value: AppLanguage.english,
                  groupValue: localeProvider.language,
                  onChanged: (value) {
                    if (value != null) localeProvider.setLanguage(value);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<AppLanguage>(
                  title: Text(AppStrings.t(context, 'language_bangla')),
                  subtitle: const Text('বাংলা'),
                  value: AppLanguage.bangla,
                  groupValue: localeProvider.language,
                  onChanged: (value) {
                    if (value != null) localeProvider.setLanguage(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
