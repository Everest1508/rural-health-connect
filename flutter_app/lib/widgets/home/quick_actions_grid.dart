import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Map action labels to localized strings
    final actionLabels = {
      'Video Consult': l10n.videoConsult,
      'Symptom Check': l10n.symptomCheck,
      'Find Medicine': l10n.findMedicine,
      'Nearby Pharmacy': l10n.nearbyPharmacy,
    };
    
    final actionDescriptions = {
      'Video Consult': l10n.talkToDoctorNow,
      'Symptom Check': l10n.aiPoweredDiagnosis,
      'Find Medicine': l10n.checkAvailabilityNearby,
      'Nearby Pharmacy': l10n.findPharmacies,
    };
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: MockData.quickActions.length,
            itemBuilder: (context, index) {
              final action = MockData.quickActions[index];
              final originalLabel = action['label'] as String;
              return _QuickActionCard(
                label: actionLabels[originalLabel] ?? originalLabel,
                description: actionDescriptions[originalLabel] ?? action['description'],
                icon: _getIconData(action['icon']),
                gradient: action['gradient'] ?? false,
                gradientType: action['gradientType'],
                color: action['color'],
                onTap: () => _handleActionTap(context, originalLabel),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'video':
        return BoxIcons.bx_video;
      case 'activity':
        return BoxIcons.bx_line_chart;
      case 'pill':
        return BoxIcons.bx_capsule;
      case 'file-text':
        return BoxIcons.bx_file;
      case 'map-pin':
        return BoxIcons.bx_map;
      case 'phone':
        return BoxIcons.bx_phone;
      default:
        return BoxIcons.bx_help_circle;
    }
  }

  void _handleActionTap(BuildContext context, String action) {
    final appState = context.read<AppState>();
    
    switch (action) {
      case 'Video Consult':
      case 'Symptom Check':
        appState.setTabIndex(2); // Navigate to Consult tab
        break;
      case 'Find Medicine':
      case 'Nearby Pharmacy':
        appState.setTabIndex(3); // Navigate to Medicines tab
        break;
      default:
        // TODO: Handle other actions
        break;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool gradient;
  final String? gradientType;
  final String? color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.gradient,
    this.gradientType,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient ? _getGradient() : null,
                color: gradient ? null : _getColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient? _getGradient() {
    if (!gradient) return null;
    
    switch (gradientType) {
      case 'primary':
        return AppTheme.primaryGradient;
      case 'accent':
        return AppTheme.accentGradient;
      default:
        return AppTheme.primaryGradient;
    }
  }

  Color _getColor() {
    switch (color) {
      case 'success':
        return AppTheme.successColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'info':
        return AppTheme.infoColor;
      case 'destructive':
        return AppTheme.destructiveColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}
