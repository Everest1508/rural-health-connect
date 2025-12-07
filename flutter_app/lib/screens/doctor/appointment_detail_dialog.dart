import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/appointment_model.dart';
import '../../core/theme/app_theme.dart';
import '../appointments/appointment_detail_screen.dart';

class AppointmentDetailDialog extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailDialog({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Patient', appointment.patientName ?? appointment.doctorName),
            _buildDetailRow(context, 'Specialty', appointment.specialty),
            _buildDetailRow(context, 'Date', appointment.date),
            _buildDetailRow(context, 'Time', appointment.time),
            _buildDetailRow(context, 'Type', appointment.typeLabel),
            _buildDetailRow(
              context,
              'Status',
              appointment.status.toString().split('.').last.toUpperCase(),
            ),
            if (appointment.type == AppointmentType.video && appointment.googleMeetLink != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_call, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Meet Link',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click to join the video call',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMeetLink(context, appointment.googleMeetLink!),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Google Meet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailScreen(
                            appointment: appointment,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Full Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMeetLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: try to open in any available mode
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Meet link: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }
}

