import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_strings.dart';
import '../../providers/theme_provider.dart';

/// Lets the user pick Light, Dark, or System Default theme. The choice is
/// applied immediately app-wide via [ThemeProvider] + MaterialApp.themeMode.
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.t(context, 'theme_title'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  secondary: const Icon(Icons.light_mode_outlined),
                  title: Text(AppStrings.t(context, 'theme_light')),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(AppStrings.t(context, 'theme_dark')),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  secondary: const Icon(Icons.settings_suggest_outlined),
                  title: Text(AppStrings.t(context, 'theme_system')),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
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
