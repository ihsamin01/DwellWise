import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/supabase_config.dart';
import 'services/deep_link_service.dart';

// Providers imports
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/property_provider.dart';
import 'providers/search_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/saved_properties_provider.dart';
import 'providers/recently_viewed_provider.dart';
import 'providers/search_filters_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/security_provider.dart';
import 'providers/app_review_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to Supabase before the app starts.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const DwellWiseApp());
}

/// Root widget initializing state management and route handlers.
class DwellWiseApp extends StatefulWidget {
  const DwellWiseApp({Key? key}) : super(key: key);

  @override
  State<DwellWiseApp> createState() => _DwellWiseAppState();
}

class _DwellWiseAppState extends State<DwellWiseApp> {
  final DeepLinkService _deepLinks = DeepLinkService();

  @override
  void initState() {
    super.initState();
    // Handle dwellwise://property/<id> shared links.
    _deepLinks.init();
  }

  @override
  void dispose() {
    _deepLinks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => SavedPropertiesProvider()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedProvider()),
        ChangeNotifierProvider(create: (_) => SearchFiltersProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => AppReviewProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'DwellWise',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
