import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../providers/app_state.dart';
import '../../widgets/layout/app_header.dart';
import '../../widgets/common/api_config_button.dart';
import '../../l10n/app_localizations.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_appointments_screen.dart';
import '../profile/profile_screen.dart';

class DoctorMainScreen extends StatelessWidget {
  const DoctorMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: IndexedStack(
                    index: appState.currentTabIndex,
                    children: const [
                      DoctorDashboardScreen(),
                      DoctorAppointmentsScreen(),
                      ProfileScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, appState),
          floatingActionButton: const ApiConfigButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                appState,
                index: 0,
                icon: BoxIcons.bx_home,
                label: l10n.dashboard,
              ),
              _buildNavItem(
                context,
                appState,
                index: 1,
                icon: BoxIcons.bx_calendar,
                label: l10n.appointments,
              ),
              _buildNavItem(
                context,
                appState,
                index: 2,
                icon: BoxIcons.bx_user,
                label: l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    AppState appState, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isActive = appState.currentTabIndex == index;
    final color = isActive ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color;

    return InkWell(
      onTap: () => appState.setTabIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: color,
        ),
      ),
    );
  }
}

