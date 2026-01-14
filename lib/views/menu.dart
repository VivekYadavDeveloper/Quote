import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:quote_vault/views/pages/favorite_page.dart';
import 'package:quote_vault/views/pages/my_profile_page.dart';
import 'package:quote_vault/views/pages/quotes_by_me_page.dart';
import 'package:quote_vault/views/pages/quotes_page.dart';
import 'package:quote_vault/views/themes/colors.dart';

enum _SelectedTab { quotes, create, favorite, profile }

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  _SelectedTab _selectedTab = _SelectedTab.quotes;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(
        index: _SelectedTab.values.indexOf(_selectedTab),
        children: const [
          QuotesPage(),
          QuotesByMePage(),
          FavoritePage(),
          MyProfile(),
        ],
      ),

      // ✅ FIXED NAV BAR
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: MyColors.secondary,
        selectedIndex: _SelectedTab.values.indexOf(_selectedTab),
        onDestinationSelected: _handleIndexChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote),
            label: "",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: "",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: "",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }

  DotNavigationBarItem _navItem({
    required bool selected,
    required String filled,
    required String outline,
  }) {
    return DotNavigationBarItem(
      icon: Image.asset(
        selected ? filled : outline,
        width: 22, // ⬅️ SAFE SIZE
        height: 22,
        fit: BoxFit.contain,
      ),
    );
  }
}
