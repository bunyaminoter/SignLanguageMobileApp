import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'camera_recognition_screen.dart';
import 'dictionary_screen.dart';
import 'home_screen.dart';
import 'text_to_sign_screen.dart';

/// Ana Navigasyon Tutucu Ekran (Modern Floating Bottom Navigation Bar)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Bottom bar şeffaf ve yüzen tasarım için
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateTab: _onTabChange),
          CameraRecognitionScreen(isActiveTab: _currentIndex == 1),
          const TextToSignScreen(),
          const DictionaryScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
