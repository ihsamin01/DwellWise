import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom systematic Bottom Navigation Bar for DwellWise.
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
        context.go('/tenant-home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/saved-listings');
        break;
      case 3:
        context.go('/chat/placeholder');
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

    final items = [
      _NavBtn(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavBtn(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Search'),
      _NavBtn(icon: Icons.favorite_border_outlined, activeIcon: Icons.favorite, label: 'Saved'),
      _NavBtn(icon: Icons.chat_bubble_outline_outlined, activeIcon: Icons.chat_bubble, label: 'Messages'),
      _NavBtn(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profile'),
    ];

    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xffD1D5DB), width: 1.0),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabTapped(context, index),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Blue line indicator at the top of active item
                  if (isActive)
                    Container(
                      width: 24,
                      height: 3,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? activeColor : inactiveColor,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? activeColor : inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
