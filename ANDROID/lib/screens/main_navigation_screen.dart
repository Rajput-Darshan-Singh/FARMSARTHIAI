import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'input_screen.dart';
import 'profile_screen.dart';
import 'schemes_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late PageController _pageController;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    SchemesListScreen(),
    InputScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF4A7C59),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          elevation: 8,
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Color(0xFF4A7C59).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance),
              ),
              label: appLocalizations.translate('governmentSchemes'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Color(0xFF4A7C59).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt),
              ),
              label: appLocalizations.translate('detectDisease'),
            ),
            // BottomNavigationBarItem(
            //   icon: AnimatedContainer(
            //     duration: Duration(milliseconds: 200),
            //     padding: EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: _currentIndex == 2
            //           ? Color(0xFF4A7C59).withOpacity(0.1)
            //           : Colors.transparent,
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Icon(Icons.history),
            //   ),
            //   label: appLocalizations.translate('history'),
            // ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Color(0xFF4A7C59).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person),
              ),
              label: appLocalizations.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
