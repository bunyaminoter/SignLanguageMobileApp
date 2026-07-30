import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../config/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withAlpha(230)
            : Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: GNav(
          rippleColor: AppColors.primary.withValues(alpha: 0.2),
          hoverColor: AppColors.primary.withValues(alpha: 0.1),
          gap: 6,
          activeColor: Colors.white,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: AppColors.primary,
          color: isDark ? Colors.white60 : Colors.black54,
          tabs: [
            GButton(
              icon: Icons.grid_view_rounded,
              text: 'nav.home'.tr(),
            ),
            GButton(
              icon: Icons.camera_front_rounded,
              text: 'nav.camera'.tr(),
            ),
            GButton(
              icon: Icons.translate_rounded,
              text: 'nav.translate'.tr(),
            ),
            GButton(
              icon: Icons.menu_book_rounded,
              text: 'nav.dictionary'.tr(),
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
