import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icedetector/screens/dashboard_screen.dart';
import 'package:icedetector/screens/detector_screen.dart';
import 'package:icedetector/screens/reports_screen.dart';
import 'package:icedetector/themes/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
        label: 'Dashboard',
        icon: Icon(Icons.house_outlined),
        activeIcon: Icon(Icons.house_rounded)
    ),
    BottomNavigationBarItem(
        label: 'Live Count',
      icon: Icon(Icons.emergency_recording_outlined),
      activeIcon: Icon(Icons.emergency_recording_rounded),
    ),
    BottomNavigationBarItem(
        label: 'Reports',
        icon: Icon(Icons.document_scanner_outlined),
        activeIcon: Icon(Icons.document_scanner_rounded),
    ),
  ];

  static const List<Widget> widgets = [
    DashboardScreen(),
    DetectorScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'icecount ai.',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize:  20
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.logout,
                  size:  25,
                )
            )
          ],
        ),
      body: Container(
        decoration: const BoxDecoration(
          color: bgColor,
        ),
        height: double.infinity,
        width: double.infinity,
        child: widgets[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700
        ),
        backgroundColor: highlightColor,
        unselectedItemColor: Colors.grey,
        selectedItemColor: primaryColor,
        currentIndex: selectedIndex,
        onTap: (int index) => setState(() {
          selectedIndex = index;
        }),
      ),
    );
  }
}
