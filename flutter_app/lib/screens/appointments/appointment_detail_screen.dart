import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/api/appointment_service.dart';
import '../../core/api/doctor_service.dart';
import '../../core/api/health_record_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../models/health_record_model.dart';
import '../../providers/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../medicines/order_pharmacy_screen.dart';
import '../health_records/add_health_record_screen.dart';
import '../health_records/file_viewer_screen.dart';
import 'package:provider/provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final HealthRecordService _healthRecordService = HealthRecordService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  
  Appointment? _currentAppointment;
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditingNotes = false;
  bool _isEditingPrescription = false;
  
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];
  String? _scheduleInfo;
  
  // Doctor location for in-person appointments
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
    _notesController.text = widget.appointment.notes ?? '';
    _prescriptionController.text = widget.appointment.prescription ?? '';
    _loadAppointmentDetails();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentDetails() async {
    setState(() => _isLoading = true);
    try {
      final appointment = await _appointmentService.getAppointment(
        int.parse(_currentAppointment!.id),
      );
      if (appointment != null && mounted) {
        setState(() {
          _currentAppointment = appointment;
          _notesController.text = appointment.notes ?? '';
          _prescriptionController.text = appointment.prescription ?? '';
        });
        // Load health records for this appointment
        await _loadHealthRecords();
      }
    } catch (e) {
      print('Error loading appointment: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHealthRecords() async {
    try {
      final records = await _healthRecordService.getHealthRecords(
        appointmentId: _currentAppointment!.id,
      );
      if (mounted) {
        setState(() {
          _healthRecords = records;
        });
      }
    } catch (e) {
      print('Error loading health records: $e');
    }
  }

  Future<void> _saveNotes() async {
    if (_currentAppointment == null) return;
    
    setState(() => _isSaving = true);
    try {
      final success = await _appointmentService.updateAppointment(
        int.parse(_currentAppointment!.id),
        notes: _notesController.text.trim(),
      );
      
      if (success && mounted) {
        await _loadAppointmentDetails();
        setState(() {
          _isEditingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _savePrescription() async {
    if (_currentAppointment == null) return;
    
    setState(() => _isSaving = true);
    try {
      final success = await _appointmentService.updateAppointment(
        int.parse(_currentAppointment!.id),
        prescription: _prescriptionController.text.trim(),
      );
      
      if (success && mounted) {
        await _loadAppointmentDetails();
        setState(() {
          _isEditingPrescription = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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

  Future<void> _loadAvailableSlots(DateTime date, {VoidCallback? onUpdate}) async {
    if (_currentAppointment?.doctorId == null) return;
    
    if (onUpdate != null) {
      onUpdate();
    } else {
      setState(() {
        _isLoadingSlots = true;
        _availableSlots = [];
        _scheduleInfo = null;
      });
    }

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final availabilityData = await _doctorService.getAvailabilityWithInfo(
        _currentAppointment!.doctorId!,
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

      if (onUpdate != null) {
        setState(() {
          _availableSlots = slots;
          _scheduleInfo = scheduleText;
          _isLoadingSlots = false;
        });
        onUpdate();
      } else {
        setState(() {
          _availableSlots = slots;
          _scheduleInfo = scheduleText;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (onUpdate != null) {
        setState(() {
          _availableSlots = [];
          _scheduleInfo = 'Unable to load available slots';
          _isLoadingSlots = false;
        });
        onUpdate();
      } else {
        setState(() {
          _availableSlots = [];
          _scheduleInfo = 'Unable to load available slots';
          _isLoadingSlots = false;
        });
      }
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
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time slot')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final timeStr = '$_selectedTimeSlot:00';
      
      final success = await _appointmentService.updateAppointment(
        int.parse(_currentAppointment!.id),
        scheduledDate: dateStr,
        scheduledTime: timeStr,
      );

      if (success && mounted) {
        await _loadAppointmentDetails();
        setState(() {
          _selectedDate = null;
          _selectedTimeSlot = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled successfully!'),
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
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openMeetLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Google Meet link: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }

  Future<void> _openDirections() async {
    if (_doctor == null || _doctor!.latitude == null || _doctor!.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor location not available'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }

    try {
      // Open Google Maps with directions
      final lat = _doctor!.latitude!;
      final lng = _doctor!.longitude!;
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to coordinates URL
        final fallbackUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open directions: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }

  Future<void> _markAsComplete() async {
    if (_currentAppointment == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete'),
        content: const Text('Are you sure you want to mark this appointment as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final success = await _appointmentService.updateAppointment(
        int.parse(_currentAppointment!.id),
        status: 'completed',
      );

      if (success && mounted) {
        await _loadAppointmentDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        throw Exception('Failed to mark appointment as complete');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);
    final isDoctor = appState.isDoctor;
    
    if (_isLoading || _currentAppointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointment Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final appointment = _currentAppointment!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          if (appointment.isUpcoming && !isDoctor)
            IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () => _showRescheduleDialog(context),
              tooltip: 'Reschedule',
            ),
          if (isDoctor && 
              appointment.status != AppointmentStatus.completed && 
              appointment.status != AppointmentStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _markAsComplete,
              tooltip: 'Mark as Complete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              (isDoctor 
                                  ? (appointment.patientName ?? 'P')
                                  : appointment.doctorName)
                                  .split(' ')
                                  .where((n) => n.isNotEmpty)
                                  .map((n) => n[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDoctor 
                                    ? (appointment.patientName ?? 'Patient')
                                    : appointment.doctorName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                appointment.specialty,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appointment.status.toString().split('.').last.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(appointment.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.date, appointment.date),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Time', appointment.time),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      appointment.type == AppointmentType.video 
                          ? Icons.video_call 
                          : Icons.local_hospital,
                      'Type',
                      appointment.typeLabel,
                    ),
                    if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.note, 'Reason', appointment.reason!),
                    ],
                    if (appointment.type == AppointmentType.video && 
                        appointment.googleMeetLink != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openMeetLink(appointment.googleMeetLink!),
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
                    if (appointment.type == AppointmentType.inPerson &&
                        _doctor != null &&
                        _doctor!.latitude != null &&
                        _doctor!.longitude != null) ...[
                      const SizedBox(height: 16),
                      if (_doctor!.clinicAddress != null && _doctor!.clinicAddress!.isNotEmpty) ...[
                        _buildInfoRow(
                          Icons.location_on,
                          AppLocalizations.of(context)!.clinicAddress,
                          _doctor!.clinicAddress!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes Section (for patients)
            if (!isDoctor) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Notes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_isEditingNotes)
                            TextButton.icon(
                              onPressed: () => setState(() => _isEditingNotes = true),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditingNotes = false;
                                      _notesController.text = appointment.notes ?? '';
                                    });
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: _isSaving ? null : _saveNotes,
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Save'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isEditingNotes)
                        TextField(
                          controller: _notesController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Add your notes about this appointment...',
                            border: OutlineInputBorder(),
                          ),
                        )
                      else
                        Text(
                          appointment.notes?.isNotEmpty == true
                              ? appointment.notes!
                              : 'No notes added yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: appointment.notes?.isNotEmpty == true
                                ? null
                                : theme.textTheme.bodySmall?.color,
                            fontStyle: appointment.notes?.isNotEmpty == true
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Prescription Section (for doctors and patients to view)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prescription',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isDoctor && !_isEditingPrescription)
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditingPrescription = true),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          )
                        else if (isDoctor && _isEditingPrescription)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditingPrescription = false;
                                    _prescriptionController.text = appointment.prescription ?? '';
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _savePrescription,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Save'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isDoctor && _isEditingPrescription)
                      TextField(
                        controller: _prescriptionController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Enter prescription details...',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(
                        appointment.prescription?.isNotEmpty == true
                            ? appointment.prescription!
                            : 'No prescription added yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appointment.prescription?.isNotEmpty == true
                              ? null
                              : theme.textTheme.bodySmall?.color,
                          fontStyle: appointment.prescription?.isNotEmpty == true
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    if (!isDoctor && appointment.prescription?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final position = await LocationService.getCurrentLocation(showError: true);
                              if (position != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderPharmacyScreen(
                                      latitude: position.latitude,
                                      longitude: position.longitude,
                                      appointment: appointment,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Order from Pharmacy'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Health Records Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health Records',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isDoctor)
                          TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddHealthRecordScreen(
                                    appointmentId: appointment.id,
                                  ),
                                ),
                              );
                              if (result == true) {
                                await _loadHealthRecords();
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Record'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_healthRecords.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          isDoctor
                              ? 'No health records added yet. Tap "Add Record" to create one.'
                              : 'No health records for this appointment.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ..._healthRecords.map((record) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.dividerColor.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _formatHealthRecordDate(record.date),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (record.createdByName != null) ...[
                                        const Spacer(),
                                        Text(
                                          'by ${record.createdByName}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    record.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record.description,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (record.attachmentUrl != null) ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => _openHealthRecordAttachment(record.attachmentUrl!),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.attach_file,
                                              size: 14,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context)!.attachmentOptional.replaceAll(' (Optional)', ''),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHealthRecordDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _openHealthRecordAttachment(String url) async {
    try {
      // Open in app viewer instead of external browser
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileViewerScreen(
            fileUrl: url,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open attachment: ${e.toString()}'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Reschedule Appointment'),
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
                      'Current Appointment',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentAppointment!.date} at ${_currentAppointment!.time}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Selection
              Text(
                'New Date',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      _selectedDate = picked;
                      _selectedTimeSlot = null;
                      _availableSlots = [];
                      _scheduleInfo = null;
                      _isLoadingSlots = true;
                    });
                    await _loadAvailableSlots(picked, onUpdate: () {
                      setDialogState(() {});
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                ),
              ),
              const SizedBox(height: 16),
              
              // Time Slot Selection
              if (_selectedDate != null) ...[
                Text(
                  'Available Time Slots',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (_scheduleInfo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _scheduleInfo!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                              setDialogState(() {
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
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Theme.of(context).dividerColor,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _formatTimeSlot(slot),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodySmall?.color,
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
                  'Time',
                  style: Theme.of(context).textTheme.titleSmall,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : () async {
              await _rescheduleAppointment();
              if (mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Reschedule'),
          ),
        ],
      ),
      ),
    );
  }
}

