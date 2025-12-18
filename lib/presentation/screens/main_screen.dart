import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'discovery_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoveryScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              );
            }
            return GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            );
          }),
        ),
        child: NavigationBar(
          height: 80,
          elevation: 2,
          backgroundColor: Theme.of(context).cardColor,
          surfaceTintColor: Theme.of(context).cardColor,
          shadowColor: Colors.black26,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
