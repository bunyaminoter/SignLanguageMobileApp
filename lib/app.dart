import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'providers/dictionary_provider.dart';
import 'providers/recognition_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/text_to_sign_provider.dart';
import 'screens/history_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';

/// Ana uygulama widget'ı
class ASLTranslatorApp extends StatelessWidget {
  final SharedPreferences prefs;
  const ASLTranslatorApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => RecognitionProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => TextToSignProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ASL Translator',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const _AppHome(),
            routes: {
              '/main': (context) => const MainNavigationScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Uygulama giriş noktası — Splash → MainNavigation / Onboarding akışı
class _AppHome extends StatefulWidget {
  const _AppHome();

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _isLoaded = false;
  bool _hasSeenOnboarding = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return _hasSeenOnboarding ? const MainNavigationScreen() : const OnboardingScreen();
    }

    return SplashScreen(
      onLoad: (onProgress) async {
        final recognitionProvider =
            context.read<RecognitionProvider>();
        await recognitionProvider.initialize(onProgress: onProgress);
        
        final prefs = await SharedPreferences.getInstance();
        _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      },
      onComplete: () {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
    );
  }
}
