import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/appointment_model.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/appointments/appointment_detail_screen.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    appointment.doctorName.split(' ').skip(1).where((n) => n.isNotEmpty).map((n) => n[0]).join('').toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      appointment.specialty,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(theme),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.date,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.time,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                appointment.type == AppointmentType.video
                    ? BoxIcons.bx_video
                    : BoxIcons.bx_clinic,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.typeLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (appointment.isUpcoming) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (appointment.type == AppointmentType.video && 
                          appointment.googleMeetLink != null) {
                        // Open Google Meet link
                        try {
                          final uri = Uri.parse(appointment.googleMeetLink!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                        } catch (e) {
                          // Error handled - URL launcher will try alternative methods
                          print('Error opening Meet link: $e');
                        }
                      } else {
                        // Navigate to appointment detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailScreen(
                              appointment: appointment,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      appointment.type == AppointmentType.video &&
                              appointment.googleMeetLink != null
                          ? 'Join Google Meet'
                          : appointment.type == AppointmentType.video
                              ? 'Join Now'
                              : 'View Details',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onCancel != null
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cancel Appointment'),
                              content: const Text(
                                'Are you sure you want to cancel this appointment?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('No'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onCancel?.call();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.destructiveColor,
                                  ),
                                  child: const Text('Yes, Cancel'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color color;
    String text;
    
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        color = AppTheme.infoColor;
        text = 'Scheduled';
        break;
      case AppointmentStatus.confirmed:
        color = AppTheme.infoColor;
        text = 'Confirmed';
        break;
      case AppointmentStatus.inProgress:
        color = AppTheme.warningColor;
        text = 'In Progress';
        break;
      case AppointmentStatus.completed:
        color = AppTheme.successColor;
        text = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        color = AppTheme.destructiveColor;
        text = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
