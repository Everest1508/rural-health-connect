import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/schedule_service.dart';
import '../../core/utils/error_handler.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _scheduleService.getSchedule();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }

  Map<String, dynamic>? _getScheduleForDay(int dayOfWeek) {
    try {
      return _schedules.firstWhere(
        (s) => s['day_of_week'] == dayOfWeek,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _editSchedule(int dayOfWeek) async {
    final existing = _getScheduleForDay(dayOfWeek);
    final dayName = _days[dayOfWeek];
    
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool isAvailable = true;
    
    if (existing != null) {
      final startStr = existing['start_time'] as String?;
      final endStr = existing['end_time'] as String?;
      isAvailable = existing['is_available'] ?? true;
      
      if (startStr != null) {
        final parts = startStr.split(':');
        startTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      if (endStr != null) {
        final parts = endStr.split(':');
        endTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ScheduleEditDialog(
        dayName: dayName,
        dayOfWeek: dayOfWeek,
        initialStartTime: startTime ?? const TimeOfDay(hour: 9, minute: 0),
        initialEndTime: endTime ?? const TimeOfDay(hour: 18, minute: 0),
        initialAvailable: isAvailable,
        scheduleId: existing?['id'],
      ),
    );
    
    if (result != null && mounted) {
      await _loadSchedule();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['id'] != null 
              ? 'Schedule updated successfully' 
              : 'Schedule created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteSchedule(int dayOfWeek) async {
    final existing = _getScheduleForDay(dayOfWeek);
    if (existing == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to remove your ${_days[dayOfWeek]} schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.destructiveColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && existing['id'] != null) {
      final success = await _scheduleService.deleteSchedule(existing['id']);
      if (mounted) {
        if (success) {
          await _loadSchedule();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete schedule'),
              backgroundColor: AppTheme.destructiveColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Set your weekly availability. Patients can only book appointments during your available hours.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Schedule List
                  ...List.generate(7, (index) {
                    final schedule = _getScheduleForDay(index);
                    return _buildScheduleCard(context, index, schedule);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    int dayOfWeek,
    Map<String, dynamic>? schedule,
  ) {
    final theme = Theme.of(context);
    final dayName = _days[dayOfWeek];
    final isAvailable = schedule != null && (schedule['is_available'] ?? true);
    
    String timeRange = 'Not set';
    if (schedule != null && isAvailable) {
      final start = schedule['start_time'] as String?;
      final end = schedule['end_time'] as String?;
      if (start != null && end != null) {
        timeRange = '${_formatTime(start)} - ${_formatTime(end)}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editSchedule(dayOfWeek),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dayName.substring(0, 3).toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isAvailable
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodySmall?.color,
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
                      dayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAvailable ? timeRange : 'Not available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isAvailable
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (schedule != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.destructiveColor,
                  onPressed: () => _deleteSchedule(dayOfWeek),
                ),
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

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeStr;
    }
  }
}

class _ScheduleEditDialog extends StatefulWidget {
  final String dayName;
  final int dayOfWeek;
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;
  final bool initialAvailable;
  final int? scheduleId;

  const _ScheduleEditDialog({
    required this.dayName,
    required this.dayOfWeek,
    required this.initialStartTime,
    required this.initialEndTime,
    required this.initialAvailable,
    this.scheduleId,
  });

  @override
  State<_ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<_ScheduleEditDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAvailable;
  bool _isSaving = false;
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _isAvailable = widget.initialAvailable;
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _saveSchedule() async {
    if (_startTime.hour * 60 + _startTime.minute >= 
        _endTime.hour * 60 + _endTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';
    final endTimeStr = '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00';

    final result = await _scheduleService.saveSchedule(
      dayOfWeek: widget.dayOfWeek,
      startTime: startTimeStr,
      endTime: endTimeStr,
      isAvailable: _isAvailable,
      scheduleId: widget.scheduleId,
    );

    setState(() => _isSaving = false);

    if (result != null && mounted) {
      Navigator.pop(context, result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save schedule'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('${widget.dayName} Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Available Toggle
            SwitchListTile(
              title: const Text('Available'),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
            ),
            const SizedBox(height: 16),
            
            // Start Time
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(
                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleLarge,
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _isAvailable ? _selectStartTime : null,
            ),
            
            // End Time
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(
                '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleLarge,
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _isAvailable ? _selectEndTime : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveSchedule,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

