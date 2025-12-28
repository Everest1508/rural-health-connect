import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/appointment_service.dart';
import '../../core/api/doctor_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/doctor_model.dart';
import '../../l10n/app_localizations.dart';

class BookAppointmentDialog extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentDialog({super.key, required this.doctor});

  @override
  State<BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<BookAppointmentDialog> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _appointmentType = 'video';
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];
  String? _scheduleInfo;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset selected time when date changes
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
      final availabilityData = await _doctorService.getAvailabilityWithInfo(
        int.parse(widget.doctor.id),
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
    // Convert "HH:MM" to "HH:MM AM/PM" format
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

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time slot')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      // Convert time slot (HH:MM) to full time format (HH:MM:SS)
      final timeStr = '$_selectedTimeSlot:00';
      
      final appointment = await _appointmentService.createAppointment(
        doctorId: int.parse(widget.doctor.id),
        appointmentType: _appointmentType,
        scheduledDate: dateStr,
        scheduledTime: timeStr,
        reason: _reasonController.text.trim(),
      );

      if (appointment != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        throw Exception('Failed to book appointment');
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
      title: Text(l10n.bookAppointmentWith(widget.doctor.name)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Appointment Type
              Text(
                'Appointment Type',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Video'),
                      selected: _appointmentType == 'video',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _appointmentType = 'video';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('In-Person'),
                      selected: _appointmentType == 'in_person',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _appointmentType = 'in_person';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Date Selection
              Text(
                AppLocalizations.of(context)!.date,
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
                  'Available Time Slots',
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
                      'No available slots for this date',
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
                const SizedBox(height: 16),
              ] else ...[
                Text(
                  'Time',
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
                    'Please select a date first to see available time slots',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for visit (optional)',
                  hintText: 'Brief description of symptoms...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _bookAppointment,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.bookAppointment),
        ),
      ],
    );
  }
}

