import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/saved_properties_provider.dart';

/// Bottom Navigation Bar with safe area adjustments, badges, and GoRouter mappings.
class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/saved');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xff1E40AF); // Primary Blue
    final inactiveColor = const Color(0xff6B7280); // Text Secondary
    final activeBgColor = const Color(0xffEFF6FF); // Light blue tint

    final savedIds = context.watch<SavedPropertiesProvider>().savedIds;
    final savedCount = savedIds.length;

    final items = [
      _NavBtn(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavBtn(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search'),
      _NavBtn(icon: Icons.favorite_border_outlined, activeIcon: Icons.favorite, label: 'Saved', showSavedCount: true),
      _NavBtn(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Messages'),
      _NavBtn(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profile'),
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 64.0 + bottomPadding,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xffD1D5DB), width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          Widget iconWidget = Icon(
            isActive ? item.activeIcon : item.icon,
            color: isActive ? activeColor : inactiveColor,
            size: 22,
          );

          if (item.showSavedCount && savedCount > 0) {
            iconWidget = Stack(
              clipBehavior: Clip.none,
              children: [
                iconWidget,
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xffDC2626), // Red badge
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$savedCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabTapped(context, index),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isActive ? activeBgColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconWidget,
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? activeColor : inactiveColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBtn {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showSavedCount;

  _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showSavedCount = false,
  });
}
