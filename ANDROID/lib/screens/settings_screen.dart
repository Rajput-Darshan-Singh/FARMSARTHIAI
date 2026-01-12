import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../providers/language_provider.dart';
import '../services/local_storage.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorage _localStorage = LocalStorage();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationsEnabled = await _localStorage.getNotificationsEnabled();
    setState(() {});
  }

  void _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _localStorage.setNotificationsEnabled(value);
  }

  void _changeLanguage(String languageCode) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLocale(Locale(languageCode));
    _localStorage.setLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.translate('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text(appLocalizations.translate('language')),
            subtitle: Text(
                '${appLocalizations.translate('current')}: ${languageProvider.currentLocale.languageCode.toUpperCase()}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(appLocalizations.translate('selectLanguage')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLanguageOption(
                          'en',
                          appLocalizations.translate('lang_en'),
                          languageProvider),
                      _buildLanguageOption(
                          'hi',
                          appLocalizations.translate('lang_hi'),
                          languageProvider),
                      _buildLanguageOption(
                          'kn',
                          appLocalizations.translate('lang_kn'),
                          languageProvider),
                      _buildLanguageOption(
                          'mr',
                          appLocalizations.translate('lang_mr'),
                          languageProvider),
                    ],
                  ),
                ),
              );
            },
          ),
          SwitchListTile(
            title: Text(appLocalizations.translate('pushNotifications')),
            subtitle: Text(appLocalizations.translate('receiveAlerts')),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text(appLocalizations.translate('clearCache')),
            subtitle: Text(appLocalizations.translate('clearAllData')),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                      appLocalizations.translate('clearCacheConfirmTitle')),
                  content: Text(
                      appLocalizations.translate('clearCacheConfirmContent')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(appLocalizations.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(appLocalizations.translate('clear')),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _localStorage.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(appLocalizations.translate('cacheCleared'))),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(appLocalizations.translate('about')),
            subtitle: Text(appLocalizations.translate('version')),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: appLocalizations.translate('applicationName'),
                applicationVersion: appLocalizations.translate('version'),
                children: [
                  Text(appLocalizations.translate('app_description')),
                  SizedBox(height: 10),
                  Text(appLocalizations.translate('developed_for')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
      String code, String name, LanguageProvider languageProvider) {
    return ListTile(
      leading: Radio(
        value: code,
        groupValue: languageProvider.currentLocale.languageCode,
        onChanged: (value) {
          _changeLanguage(value.toString());
          Navigator.pop(context);
        },
      ),
      title: Text(name),
      onTap: () {
        _changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}
