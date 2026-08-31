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
  State<MainTabsShell> createState() => MainTabsShellState();
}

class MainTabsShellState extends State<MainTabsShell> {
  late int _currentIndex;
  final GlobalKey<TenantHomeScreenState> _homeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 5);
    // Load the signed-in user's profile (covers restored "keep me signed in".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UserProvider>().loadCurrentUserProfile();
    });
  }

  /// Handles a back request on this tab shell (system back button, or the
  /// shell's own back arrow). Returns true only once the user has actually
  /// confirmed exiting the app; every other case is handled internally
  /// (switching to Home, or clearing an active filter) and returns false.
  ///
  /// This is called both from [onExit] on the shell's GoRoutes -- needed
  /// because go_router's back-button handling checks `Navigator.canPop()`
  /// (route-stack depth) before ever consulting PopScope, and this shell is
  /// normally the only route on the stack -- and from the PopScope below,
  /// which still helps when something has been pushed on top of the shell.
  Future<bool> confirmBackNavigation() async {
    // From a non-home tab, back returns to the Home tab first.
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    // On the Home tab, a leftover filter is cleared first; only a
    // second back press (nothing left to reset) asks to exit the app.
    if (_homeKey.currentState?.hasActiveFilters ?? false) {
      _homeKey.currentState!.clearFilters();
      return false;
    }
    return showExitConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await confirmBackNavigation();
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TenantHomeScreen(key: _homeKey, showBottomNavigation: false),
            const TenantSearchScreen(showBottomNavigation: false),
            const AiAssistantScreen(),
            const TenantSavedScreen(showBottomNavigation: false),
            const ChatsScreen(),
            ProfileScreen(onBackToHome: () => setState(() => _currentIndex = 0)),
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
