import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../notifications/notifications_screen.dart';
import '../doctor/doctor_schedule_screen.dart';
import '../doctor/doctor_location_screen.dart';
import '../pharmacist/pharmacist_store_location_screen.dart';
import '../health_records/health_records_screen.dart';
import '../settings/language_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      appState.userName.split(' ').where((n) => n.isNotEmpty).map((n) => n[0]).join('').toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  appState.userName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appState.userLocation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Menu Items
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_user,
            title: l10n.personalInformation,
            onTap: () => _showPersonalInformationDialog(context, appState),
          ),
          // Doctor-specific menu items
          if (appState.isDoctor) ...[
            _buildMenuItem(
              context,
              icon: BoxIcons.bx_calendar_check,
              title: 'My Schedule',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorScheduleScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: BoxIcons.bx_map,
              title: 'Clinic Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorLocationScreen(),
                  ),
                );
              },
            ),
          ],
          // Pharmacist-specific menu items
          if (appState.isPharmacist)
            _buildMenuItem(
              context,
              icon: BoxIcons.bx_store,
              title: 'Store Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PharmacistStoreLocationScreen(),
                  ),
                );
              },
            ),
          // Health Records (for patients only)
          if (!appState.isDoctor && !appState.isPharmacist)
            _buildMenuItem(
              context,
              icon: BoxIcons.bx_file_blank,
              title: l10n.healthRecords,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthRecordsScreen(),
                  ),
                );
              },
            ),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_bell,
            title: l10n.notifications,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_moon,
            title: l10n.darkMode,
            trailing: Switch(
              value: appState.themeMode == ThemeMode.dark,
              onChanged: (value) {
                appState.toggleTheme();
              },
            ),
          ),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_globe,
            title: l10n.language,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.locale.languageCode == 'hi' ? 'हिंदी' : 'English',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_help_circle,
            title: l10n.helpSupport,
            onTap: () => _showHelpSupport(context),
          ),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_info_circle,
            title: l10n.about,
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            icon: BoxIcons.bx_log_out,
            title: l10n.logout,
            textColor: AppTheme.destructiveColor,
            onTap: () => _showLogoutDialog(context, appState),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
              Icon(
                icon,
                color: textColor ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: theme.textTheme.bodySmall?.color,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonalInformationDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController(text: appState.userName);
    final locationController = TextEditingController(text: appState.userLocation);
    final emailController = TextEditingController(text: appState.userEmail);
    final phoneController = TextEditingController(text: appState.userPhone);

    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.personalInformation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await appState.updateUserInfo(
                nameController.text.trim(),
                locationController.text.trim(),
              );
              Navigator.pop(context);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Unable to update profile. Please try again.'),
                    backgroundColor: AppTheme.destructiveColor,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
        );
      },
    );
  }


  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Call Support'),
              subtitle: const Text('+91 1800-123-4567'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling support...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email Support'),
              subtitle: const Text('support@ruralhealth.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening chat...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('FAQs'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening FAQs...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Swasth Setu',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.medical_services,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Swasth Setu is a healthcare platform designed to bring quality healthcare services to communities.',
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2024 Swasth Setu. All rights reserved.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appState.logout();
              // Navigation will be handled automatically by main.dart
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.destructiveColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
