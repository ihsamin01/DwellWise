import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/exit_confirmation.dart';
import '../chat/chats_screen.dart';
import '../common/profile_screen.dart';
import '../assistant/ai_assistant_screen.dart';
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
    _currentIndex = widget.initialIndex.clamp(0, 5);
    // Load the signed-in user's profile (covers restored "keep me signed in".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UserProvider>().loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // From a non-home tab, back returns to the Home tab first.
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        // On the Home tab, back asks to exit the app.
        final shouldExit = await showExitConfirmationDialog(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            TenantHomeScreen(showBottomNavigation: false),
            TenantSearchScreen(showBottomNavigation: false),
            AiAssistantScreen(),
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
      ),
    );
  }
}
