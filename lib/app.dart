import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/dictionary_provider.dart';
import 'providers/recognition_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/text_to_sign_provider.dart';
import 'screens/history_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

/// Ana uygulama widget'ı
class ASLTranslatorApp extends StatelessWidget {
  const ASLTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RecognitionProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => TextToSignProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ASL Translator',
            debugShowCheckedModeBanner: false,
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

/// Uygulama giriş noktası — Splash → MainNavigation akışı
class _AppHome extends StatefulWidget {
  const _AppHome();

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return const MainNavigationScreen();
    }

    return SplashScreen(
      onLoad: (onProgress) async {
        final recognitionProvider =
            context.read<RecognitionProvider>();
        await recognitionProvider.initialize(onProgress: onProgress);
      },
      onComplete: () {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
    );
  }
}
