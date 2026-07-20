import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../chat/chats_screen.dart';
import '../common/profile_screen.dart';
import '../tenant/home_screen.dart';
import '../tenant/saved_screen.dart';
import '../tenant/search_screen.dart';

/// Persistent bottom-tab shell that keeps each tab alive in an IndexedStack.
class MainTabsShell extends StatefulWidget {
  final int initialIndex;

  const MainTabsShell({
    super.key,
    required this.initialIndex,
  });

  @override
  State<MainTabsShell> createState() => _MainTabsShellState();
}

class _MainTabsShellState extends State<MainTabsShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TenantHomeScreen(showBottomNavigation: false),
          TenantSearchScreen(showBottomNavigation: false),
          TenantSavedScreen(showBottomNavigation: false),
          ChatsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        messagesUnreadCount: chatProvider.unreadConversationCount,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
