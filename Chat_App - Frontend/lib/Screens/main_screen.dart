import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_app/Screens/profile_screen.dart';
import 'chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> viewContainer = [
    ChatScreen(),
    ProfileScreen(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    if (index != 1) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 4.0,
        icon: const Icon(FontAwesomeIcons.peopleGroup),
        label: const Text(' Friends'),
        onPressed: () {
          Navigator.pushNamed(context, 'FriendsScreen');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped, // new
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.message),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
      body: viewContainer[currentIndex],
    );
  }
}
