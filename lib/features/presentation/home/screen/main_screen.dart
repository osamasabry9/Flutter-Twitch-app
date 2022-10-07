import 'package:flutter/material.dart';
import 'package:twitch_clone/features/presentation/browser/screen/browser_screen.dart';
import 'package:twitch_clone/features/presentation/home/screen/home_screen.dart';
import 'package:twitch_clone/features/presentation/live/screen/go_live_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  onTapChange(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController!.index = _selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children:  [
          const HomeScreen(),
          GoLiveScreen(),
          const BrowserScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
              ),
              label: 'Following'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_rounded,
              ),
              label: 'Go Live'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.copy,
              ),
              label: 'Browse'),
        ],
        currentIndex: _selectedIndex,
        onTap: onTapChange,
      ),
    );
  }
}
