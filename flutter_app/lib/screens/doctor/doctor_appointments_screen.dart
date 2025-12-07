import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/appointment_service.dart';
import '../../models/appointment_model.dart';
import 'appointment_detail_dialog.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
        _applyFilter();
      });
    } catch (e) {
      print('Error loading appointments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedFilter) {
        case 'today':
          final today = DateTime.now();
          _filteredAppointments = _appointments.where((apt) {
            try {
              final aptDate = DateTime.parse(apt.rawDate);
              return aptDate.year == today.year &&
                  aptDate.month == today.month &&
                  aptDate.day == today.day;
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case 'upcoming':
          final now = DateTime.now();
          _filteredAppointments = _appointments.where((apt) {
            try {
              final aptDate = DateTime.parse(apt.rawDate);
              return aptDate.isAfter(now) &&
                  (apt.status == AppointmentStatus.scheduled ||
                      apt.status == AppointmentStatus.confirmed);
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case 'completed':
          _filteredAppointments = _appointments
              .where((apt) => apt.status == AppointmentStatus.completed)
              .toList();
          break;
        default:
          _filteredAppointments = _appointments;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('today', 'Today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('upcoming', 'Upcoming'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'Completed'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Appointments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _filteredAppointments[index];
                            return _buildAppointmentCard(context, appointment);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context, appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    (appointment.patientName ?? appointment.doctorName)
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join(),
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
                      appointment.patientName ?? appointment.doctorName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.date} at ${appointment.time}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      appointment.specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      appointment.status.toString().split('.').last.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(appointment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appointment.typeLabel,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Appointments will appear here',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (_) => AppointmentDetailDialog(appointment: appointment),
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
}

