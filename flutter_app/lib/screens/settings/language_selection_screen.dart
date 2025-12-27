import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../core/theme/app_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {'code': 'en', 'name': 'English', 'nativeName': l10n.english},
      {'code': 'hi', 'name': 'Hindi', 'nativeName': l10n.hindi},
      {'code': 'mr', 'name': 'Marathi', 'nativeName': l10n.marathi},
      {'code': 'pa', 'name': 'Punjabi', 'nativeName': l10n.punjabi},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = appState.locale.languageCode == language['code'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                language['nativeName']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                language['name']!,
                style: theme.textTheme.bodyMedium,
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                    ),
              onTap: () {
                appState.setLocale(Locale(language['code']!));
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}

