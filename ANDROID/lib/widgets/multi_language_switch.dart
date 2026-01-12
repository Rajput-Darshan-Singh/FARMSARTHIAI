import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../app_localizations.dart';

class MultiLanguageSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLocale.languageCode;
    final theme = Theme.of(context);

    final languages = [
      {
        'code': 'en',
        'name': AppLocalizations.of(context).translate('lang_en'),
        'flag': '🇬🇧'
      },
      {
        'code': 'hi',
        'name': AppLocalizations.of(context).translate('lang_hi'),
        'flag': '🇮🇳'
      },
      {
        'code': 'kn',
        'name': AppLocalizations.of(context).translate('lang_kn'),
        'flag': '🇮🇳'
      },
      {
        'code': 'mr',
        'name': AppLocalizations.of(context).translate('lang_mr'),
        'flag': '🇮🇳'
      },
    ];

    return IconButton(
      icon: Icon(Icons.language),
      tooltip: AppLocalizations.of(context).translate('changeLanguageTooltip'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.language, color: theme.colorScheme.primary),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context).translate('selectLanguage')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: languages.map((lang) {
                  return _buildLanguageOption(
                    context,
                    lang['code']!,
                    lang['name']!,
                    lang['flag']!,
                    currentLanguage,
                    theme,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    String flag,
    String currentLanguage,
    ThemeData theme,
  ) {
    final isSelected = code == currentLanguage;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Text(
          flag,
          style: TextStyle(fontSize: 24),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            : null,
        onTap: () {
          final languageProvider =
              Provider.of<LanguageProvider>(context, listen: false);
          languageProvider.setLocale(Locale(code, code == 'en' ? 'US' : 'IN'));
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
