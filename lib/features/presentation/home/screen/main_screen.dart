import 'package:flutter/material.dart';
import 'package:twitch_clone/features/presentation/browser/screen/browser_screen.dart';
import 'package:twitch_clone/features/presentation/home/screen/home_screen.dart';
import 'package:twitch_clone/features/presentation/live/screen/go_live_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 0;
  List<Widget> pages = const [
    HomeScreen(),
    GoLiveScreen(),
    BrowserScreen(),
  ];

  onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
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
        onTap: onPageChange,
        currentIndex: _page,
      ),
    );
  }
}
