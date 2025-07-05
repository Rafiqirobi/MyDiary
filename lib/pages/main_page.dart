import 'package:flutter/material.dart';
import 'package:mydiary/pages/home_page.dart';
import 'package:mydiary/pages/profile_page.dart';
import 'package:mydiary/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  MainPage({required this.isDarkMode, required this.onThemeChanged});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      ProfilePage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ], // Navigation bar with three destinations
      ), // Bottom navigation bar
    );
  }
}
