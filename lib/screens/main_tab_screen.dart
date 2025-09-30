import 'package:flutter/material.dart';
import '../services/call_manager.dart';
import 'chat_list_screen.dart';
import 'stories_screen.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;

  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize call manager to listen for incoming calls
    CallManager().initialize(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ChatListScreen(),
          StoriesScreen(),
          ContactsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2327).withOpacity(0.8),
          border: const Border(
            top: BorderSide(color: Color(0xFF283339), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.chat_bubble_outlined,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Chats',
                  index: 0,
                ),
                _buildBottomNavItem(
                  icon: Icons.auto_stories_outlined,
                  selectedIcon: Icons.auto_stories,
                  label: 'Stories',
                  index: 1,
                ),
                _buildBottomNavItem(
                  icon: Icons.group_outlined,
                  selectedIcon: Icons.group,
                  label: 'Contacts',
                  index: 2,
                  hasNotification: true,
                ),
                _buildBottomNavItem(
                  icon: Icons.person_outlined,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    bool hasNotification = false,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? const Color(0xFF13A4EC) : Colors.grey[400],
                size: isSelected ? 28 : 24,
              ),
              if (hasNotification && isSelected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF13A4EC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF13A4EC) : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
