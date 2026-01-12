import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../widgets/menu_drawer.dart';
// language switch removed from header
import 'input_screen.dart';
import 'help_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'schemes_list_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('home')),
      ),
      drawer: MenuDrawer(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            Icons.camera_alt,
            appLocalizations.translate('detectDisease'),
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InputScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            Icons.account_balance,
            'Government Schemes',
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SchemesListScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            Icons.help,
            appLocalizations.translate('help'),
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            Icons.person,
            appLocalizations.translate('profile'),
            Colors.teal,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
          _buildMenuCard(
            context,
            Icons.settings,
            appLocalizations.translate('settings'),
            Colors.grey,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
