import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../l10n/app_localizations.dart';

class HealthTipsSection extends StatelessWidget {
  const HealthTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.healthTips,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...MockData.healthTips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HealthTipCard(
                  context: context,
                  icon: tip['icon']!,
                  titleKey: tip['title']!,
                  descriptionKey: tip['description']!,
                ),
              )),
        ],
      ),
    );
  }
}

class _HealthTipCard extends StatelessWidget {
  final BuildContext context;
  final String icon;
  final String titleKey;
  final String descriptionKey;

  const _HealthTipCard({
    required this.context,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Map title keys to localized strings
    final titleMap = {
      'Stay Hydrated': l10n.stayHydrated,
      'Regular Exercise': l10n.regularExercise,
      'Balanced Diet': l10n.balancedDiet,
      'Quality Sleep': l10n.qualitySleep,
    };
    
    // Map description keys to localized strings
    final descriptionMap = {
      'Drink at least 8 glasses of water daily': l10n.drinkAtLeast8Glasses,
      '30 minutes of physical activity each day': l10n.thirtyMinutesPhysicalActivity,
      'Include fruits and vegetables in every meal': l10n.includeFruitsVegetables,
      'Get 7-8 hours of sleep every night': l10n.get7To8HoursSleep,
    };
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleMap[titleKey] ?? titleKey,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descriptionMap[descriptionKey] ?? descriptionKey,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
