import 'package:app/screens/classes.dart';
import 'package:app/screens/students.dart';
import 'package:app/widgets/app_padding.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Widget> pages = [
    ClassesScreen(),
    StudentsScreen(),
    ClassesScreen(),
    ClassesScreen(),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPadding(
        child: pages[selectedIndex],
      ),
      backgroundColor: colourPalette.neutralTint.tint100,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: colourPalette.primary.primary500,
        currentIndex: selectedIndex,
        onTap: (int index) {
          setState(
            () {
              selectedIndex = index;
            },
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Classes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Students",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
