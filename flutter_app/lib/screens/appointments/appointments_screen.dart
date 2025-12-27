import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import '../../widgets/appointments/appointment_card.dart';
import '../../core/api/appointment_service.dart';
import '../../core/api/doctor_service.dart';
import '../../core/utils/error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/consult/book_appointment_dialog.dart';
import '../../models/doctor_model.dart';
import '../../l10n/app_localizations.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.appointments,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBookAppointmentDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.book),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: theme.colorScheme.onSurface,
              unselectedLabelColor: theme.textTheme.bodySmall?.color,
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  height: 40,
                  child: Center(child: Text(AppLocalizations.of(context)!.upcoming)),
                ),
                Tab(
                  height: 40,
                  child: Center(child: Text(AppLocalizations.of(context)!.completed)),
                ),
                Tab(
                  height: 40,
                  child: Center(child: Text(AppLocalizations.of(context)!.cancelled)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentsList('upcoming'), // Shows scheduled and confirmed
              _buildAppointmentsList(AppointmentStatus.completed),
              _buildAppointmentsList(AppointmentStatus.cancelled),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showBookAppointmentDialog(BuildContext context) async {
    try {
      final doctors = await _doctorService.getDoctors();
      if (doctors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No doctors available')),
        );
        return;
      }
      
      // Show doctor selection dialog first
      final selectedDoctor = await showDialog<Doctor>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Doctor'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return ListTile(
                  title: Text(doctor.name),
                  subtitle: Text(doctor.specialty),
                  trailing: Text('₹${doctor.fee}'),
                  onTap: () => Navigator.pop(context, doctor),
                );
              },
            ),
          ),
        ),
      );

      if (selectedDoctor != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => BookAppointmentDialog(doctor: selectedDoctor),
        ).then((_) => _loadAppointments());
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
    }
  }

  Widget _buildAppointmentsList(dynamic status) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    List<Appointment> appointments;
    if (status == 'upcoming') {
      // Show both scheduled and confirmed as "upcoming"
      appointments = _appointments
          .where((apt) => apt.status == AppointmentStatus.scheduled || 
                         apt.status == AppointmentStatus.confirmed)
          .toList();
    } else {
      appointments = _appointments
          .where((apt) => apt.status == status)
          .toList();
    }

    if (appointments.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(
                      appointment: appointments[index],
                    ),
                  ),
                ).then((_) => _loadAppointments());
              },
              child: AppointmentCard(
                appointment: appointments[index],
                onCancel: () async {
                  final success = await _appointmentService.cancelAppointment(
                    int.parse(appointments[index].id),
                  );
                  if (success && mounted) {
                    _loadAppointments();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Appointment cancelled')),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(dynamic status) {
    final theme = Theme.of(context);
    String statusText;
    if (status == 'upcoming') {
      statusText = 'Upcoming';
    } else {
      statusText = status.toString().split('.').last;
      statusText = statusText[0].toUpperCase() + statusText.substring(1);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Text('📅', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No $statusText Appointments',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ${statusText.toLowerCase()} appointments will appear here',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
