import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../providers/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/appointment_service.dart';
import '../../models/appointment_model.dart';
import 'doctor_appointments_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _todayAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  bool _isLoading = true;
  int _totalAppointments = 0;
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _todayAppointments = appointments.where((apt) {
        try {
          final aptDate = DateTime.parse(apt.rawDate);
          return aptDate.year == today.year &&
              aptDate.month == today.month &&
              aptDate.day == today.day &&
              (apt.status == AppointmentStatus.scheduled ||
                  apt.status == AppointmentStatus.confirmed);
        } catch (e) {
          return false;
        }
      }).toList();

      _upcomingAppointments = appointments
          .where((apt) {
            try {
              final aptDate = DateTime.parse(apt.rawDate);
              return aptDate.isAfter(today) &&
                  (apt.status == AppointmentStatus.scheduled ||
                      apt.status == AppointmentStatus.confirmed);
            } catch (e) {
              return false;
            }
          })
          .take(3)
          .toList();

      _totalAppointments = appointments.length;
      _todayCount = _todayAppointments.length;
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context);

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Dr. ${appState.userName}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your appointments and patients',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Today',
                    _todayCount.toString(),
                    BoxIcons.bx_calendar_check,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total',
                    _totalAppointments.toString(),
                    BoxIcons.bx_calendar,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Appointments",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorAppointmentsScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_todayAppointments.isEmpty)
              _buildEmptyState(
                context,
                'No appointments scheduled for today',
                BoxIcons.bx_calendar,
              )
            else
              ..._todayAppointments.map((apt) => _buildAppointmentCard(context, apt)),
            const SizedBox(height: 24),

            // Upcoming Appointments
            Text(
              'Upcoming Appointments',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_upcomingAppointments.isEmpty)
              _buildEmptyState(
                context,
                'No upcoming appointments',
                BoxIcons.bx_calendar,
              )
            else
              ..._upcomingAppointments.map((apt) => _buildAppointmentCard(context, apt)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child:                   Text(
                    (appointment.patientName ?? appointment.doctorName)
                        .split(' ')
                        .map((n) => n.isNotEmpty ? n[0] : '')
                        .take(2)
                        .join(),
                    style: theme.textTheme.titleMedium?.copyWith(
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
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  appointment.typeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
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
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

