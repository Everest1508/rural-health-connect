import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/appointment_service.dart';
import '../../core/api/doctor_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/appointment_model.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UpcomingAppointmentCard extends StatefulWidget {
  const UpcomingAppointmentCard({super.key});

  @override
  State<UpcomingAppointmentCard> createState() => _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  Appointment? _upcomingAppointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingAppointment();
  }

  Future<void> _loadUpcomingAppointment() async {
    try {
      final appointments = await _appointmentService.getAppointments();
      final upcoming = appointments
          .where((apt) => apt.status == AppointmentStatus.scheduled || 
                         apt.status == AppointmentStatus.confirmed)
          .toList();
      
      if (upcoming.isNotEmpty) {
        setState(() {
          _upcomingAppointment = upcoming.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading || _upcomingAppointment == null) {
      return const SizedBox.shrink();
    }

    final appointment = _upcomingAppointment!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.upcomingAppointments,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  appState.setTabIndex(1); // Navigate to appointments tab
                },
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.25),
                  blurRadius: 16,
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
                        color: Colors.white.withOpacity(0.2),
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            appointment.specialty,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.date,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appointment.time,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleJoinNow(context, appointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          appointment.type == AppointmentType.video &&
                                  appointment.googleMeetLink != null
                              ? l10n.joinGoogleMeet
                              : appointment.type == AppointmentType.video
                                  ? l10n.joinNow
                                  : l10n.viewDetails,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => _showRescheduleDialog(context, appointment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(l10n.reschedule),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinNow(BuildContext context, Appointment appointment) async {
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
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.couldNotOpenGoogleMeetLink}: $e'),
              backgroundColor: AppTheme.destructiveColor,
            ),
          );
        }
      }
    } else {
      // Navigate to appointments screen for in-person appointments
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setTabIndex(1);
    }
  }

  Future<void> _showRescheduleDialog(BuildContext context, Appointment appointment) async {
    if (appointment.doctorId == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotRescheduleDoctorInfoMissing),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => _RescheduleDialog(
        appointment: appointment,
        appointmentService: _appointmentService,
        doctorService: _doctorService,
        onRescheduled: () {
          // Reload upcoming appointment after rescheduling
          _loadUpcomingAppointment();
        },
      ),
    );
  }
}

class _RescheduleDialog extends StatefulWidget {
  final Appointment appointment;
  final AppointmentService appointmentService;
  final DoctorService doctorService;
  final VoidCallback onRescheduled;

  const _RescheduleDialog({
    required this.appointment,
    required this.appointmentService,
    required this.doctorService,
    required this.onRescheduled,
  });

  @override
  State<_RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<_RescheduleDialog> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];
  String? _scheduleInfo;

  @override
  void initState() {
    super.initState();
    // Parse current appointment date
    try {
      _selectedDate = DateTime.parse(widget.appointment.rawDate);
    } catch (e) {
      // If parsing fails, set to tomorrow
      _selectedDate = DateTime.now().add(const Duration(days: 1));
    }
    // Load available slots for the current date
    if (_selectedDate != null) {
      _loadAvailableSlots(_selectedDate!);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
        _availableSlots = [];
        _scheduleInfo = null;
      });
      await _loadAvailableSlots(picked);
    }
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _scheduleInfo = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final availabilityData = await widget.doctorService.getAvailabilityWithInfo(
        widget.appointment.doctorId!,
        dateStr,
      );

      final slots = availabilityData['slots'] as List<String>;
      final schedule = availabilityData['schedule'] as Map<String, dynamic>?;
      final message = availabilityData['message'] as String?;

      String? scheduleText;
      if (schedule != null) {
        final startTime = schedule['start_time'] as String?;
        final endTime = schedule['end_time'] as String?;
        if (startTime != null && endTime != null) {
          // Note: We can't use l10n here as this is called from initState
          // The schedule info will be displayed in the dialog which has access to context
          scheduleText = 'Available: $startTime - $endTime';
        }
      } else if (message != null && slots.isEmpty) {
        scheduleText = message;
      }

      setState(() {
        _availableSlots = slots;
        _scheduleInfo = scheduleText;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _availableSlots = [];
        _scheduleInfo = 'Unable to load available slots';
        _isLoadingSlots = false;
      });
    }
  }

  String _formatTimeSlot(String timeSlot) {
    try {
      final parts = timeSlot.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {
      // If parsing fails, return original
    }
    return timeSlot;
  }

  Future<void> _rescheduleAppointment() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectDateAndTimeSlot)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr = '$_selectedTimeSlot:00';
      
      final success = await widget.appointmentService.updateAppointment(
        int.parse(widget.appointment.id),
        scheduledDate: dateStr,
        scheduledTime: timeStr,
      );

      if (success && mounted) {
        Navigator.pop(context);
        widget.onRescheduled();
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentRescheduledSuccessfully),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        throw Exception('Failed to reschedule appointment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: AppTheme.destructiveColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.rescheduleAppointment),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Appointment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedForeground.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.currentAppointment,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appointmentAt(widget.appointment.date, widget.appointment.time),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            Text(
              l10n.newDate,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? AppLocalizations.of(context)!.selectDate
                    : DateFormat('MMM dd, yyyy').format(_selectedDate!),
              ),
            ),
            const SizedBox(height: 16),
            
            // Time Slot Selection
            if (_selectedDate != null) ...[
              Text(
                l10n.availableTimeSlots,
                style: theme.textTheme.titleSmall,
              ),
              if (_scheduleInfo != null) ...[
                const SizedBox(height: 4),
                Text(
                  _scheduleInfo!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _availableSlots.isEmpty 
                        ? AppTheme.destructiveColor 
                        : AppTheme.successColor,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (_isLoadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.mutedForeground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.noAvailableSlotsForThisDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: _availableSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTimeSlot = slot;
                            });
                          },
                          child: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : theme.dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _formatTimeSlot(slot),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.textTheme.bodySmall?.color,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ] else ...[
              Text(
                l10n.time,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.mutedForeground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.pleaseSelectDateFirst,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _rescheduleAppointment,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.reschedule),
        ),
      ],
    );
  }
}
