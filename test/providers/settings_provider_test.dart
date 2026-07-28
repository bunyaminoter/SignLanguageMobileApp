import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/providers/settings_provider.dart';

void main() {
  group('SettingsProvider Tests', () {
    late SettingsProvider settingsProvider;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsProvider = SettingsProvider(prefs);
    });

    test('Initial values should be defaults if no prefs set', () {
      expect(settingsProvider.isDarkMode, true); // default is true
      expect(settingsProvider.ttsEnabled, true);
      expect(settingsProvider.confidenceThreshold, 0.7);
    });

    test('Toggling dark mode should update state and prefs', () async {
      final initialMode = settingsProvider.isDarkMode;
      settingsProvider.toggleDarkMode();
      await Future.delayed(Duration.zero);
      expect(settingsProvider.isDarkMode, !initialMode);
      expect(prefs.getBool('isDarkMode'), !initialMode);
    });

    test('Updating confidence threshold should save to prefs', () async {
      settingsProvider.updateConfidenceThreshold(0.85);
      await Future.delayed(Duration.zero);
      expect(settingsProvider.confidenceThreshold, 0.85);
      expect(prefs.getDouble('confidenceThreshold'), 0.85);
    });
  });
}
