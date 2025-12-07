import 'package:flutter/material.dart';
import '../../widgets/home/search_bar_widget.dart';
import '../../widgets/home/quick_actions_grid.dart';
import '../../widgets/home/upcoming_appointment_card.dart';
import '../../widgets/home/doctors_list.dart';
import '../../widgets/home/health_tips_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SearchBarWidget(),
          SizedBox(height: 8),
          QuickActionsGrid(),
          SizedBox(height: 8),
          UpcomingAppointmentCard(),
          SizedBox(height: 8),
          DoctorsList(),
          SizedBox(height: 8),
          HealthTipsSection(),
          SizedBox(height: 80), // Bottom padding for navigation bar
        ],
      ),
    );
  }
}
