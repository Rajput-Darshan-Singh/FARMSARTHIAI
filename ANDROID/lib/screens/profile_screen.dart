import 'package:crop_disease_app/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../providers/language_provider.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'user_data_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  String? _userName;
  String? _userNumber;
  String? _userLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? '';
        _userNumber = prefs.getString('user_number') ?? '';
        _userLocation = prefs.getString('user_location') ?? '';

        _nameController.text = _userName ?? '';
        _phoneController.text = _userNumber ?? '';
        _locationController.text = _userLocation ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text);
      await prefs.setString('user_number', _phoneController.text);

      setState(() {
        _userName = _nameController.text;
        _userNumber = _phoneController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: Color(0xFF4A7C59),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.translate('profile')),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('profile')),
        backgroundColor: Color(0xFF4A7C59),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA8D5BA).withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4A7C59),
                            Color(0xFF6B9F78),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4A7C59).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // User Name
                Text(
                  _userName?.isNotEmpty == true ? _userName! : 'Farmer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A7C59),
                  ),
                ),
                SizedBox(height: 8),
                if (true)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A7C59).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Language: ${languageProvider.currentLocale.languageCode.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A7C59),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 32),
                // User Info Cards
                _buildInfoCard(
                  context,
                  Icons.person_outline,
                  'Name',
                  _nameController,
                  'Enter your name',
                ),
                SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  Icons.phone_outlined,
                  'Phone Number',
                  _phoneController,
                  'Enter your phone number',
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                _buildLanguageCard(context, appLocalizations, languageProvider),
                SizedBox(height: 16),
                _buildInfoCard(
                  context,
                  Icons.location_on_outlined,
                  'Location',
                  _locationController,
                  'Your current location',
                  enabled: false,
                ),
                SizedBox(height: 32),
                // Update Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A7C59).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: Icon(Icons.save, size: 24),
                    label: Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A7C59),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Menu Options
                _buildMenuCard(
                  context,
                  Icons.settings,
                  'Settings',
                  'App preferences and configurations',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  'FAQs and contact support',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpScreen()),
                    );
                  },
                ),
                SizedBox(height: 24),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(appLocalizations.translate('logout')),
                          content: Text(appLocalizations
                              .translate('logoutConfirmContent')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLocalizations.translate('cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                // Thorough cleanup of local storage and files
                                try {
                                  await LocalStorage().clearAllExpanded();
                                } catch (_) {}

                                // Clear all local storage and files
                                try {
                                  await LocalStorage().clearAllExpanded();
                                } catch (_) {}

                                // Navigate to the user-data entry screen so user can re-enter details
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => UserDataScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                              ),
                              child:
                                  Text(appLocalizations.translate('confirm')),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.logout, color: theme.colorScheme.error),
                    label: Text(
                      appLocalizations.translate('logout'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clears all saved user data
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4A7C59).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4A7C59)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: enabled
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF4A7C59).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Color(0xFF4A7C59),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A7C59),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context,
      AppLocalizations appLocalizations, LanguageProvider languageProvider) {
    final currentCode = languageProvider.currentLocale.languageCode;
    final labelKey = 'lang_${currentCode}';
    final label = appLocalizations.translate(labelKey);

    return GestureDetector(
      onTap: () =>
          _showLanguageSelector(context, appLocalizations, languageProvider),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF4A7C59).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language,
              color: Color(0xFF4A7C59),
              size: 24,
            ),
          ),
          title: Text(
            appLocalizations.translate('language'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7C59),
            ),
          ),
          subtitle: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
          onTap: () => _showLanguageSelector(
              context, appLocalizations, languageProvider),
        ),
      ),
    );
  }

  void _showLanguageSelector(
      BuildContext context,
      AppLocalizations appLocalizations,
      LanguageProvider languageProvider) async {
    final locales = languageProvider.supportedLocales;
    final selected = await showDialog<Locale>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(appLocalizations.translate('selectLanguage')),
          children: locales.map((locale) {
            final code = locale.languageCode;
            final key = 'lang_${code}';
            final label = appLocalizations.translate(key);
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, locale),
              child: Text(label),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      await languageProvider.setLocale(selected);
      // LocalStorage updated inside provider; force rebuild
      setState(() {});
    }
  }
}
