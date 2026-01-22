import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/brand_theme.dart';
import 'core/constants/brand_colors.dart';
import 'core/router/app_router.dart';
import 'core/providers/preferences_provider.dart';
import 'features/project/providers/project_provider.dart';
import 'features/ai_scope/providers/scope_provider.dart';
import 'features/estimate/providers/estimate_provider.dart';
import 'features/cost_config/providers/cost_config_provider.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Notifications
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ScopeProvider()),
        ChangeNotifierProvider(create: (_) => EstimateProvider()),
        ChangeNotifierProvider(create: (_) => CostConfigProvider()),
      ],
      child: const DesignQuoteApp(),
    ),
  );
}

class DesignQuoteApp extends StatelessWidget {
  const DesignQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    return MaterialApp.router(
      title: BrandConstants.brandName, // 'DesignQuote AI'
      theme: BrandTheme.lightTheme,
      darkTheme: BrandTheme.darkTheme,
      themeMode: prefs.themeMode,
      locale: prefs.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('gu', 'IN'),
      ],
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
