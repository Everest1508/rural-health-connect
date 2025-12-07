import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../widgets/consult/doctor_booking_view.dart';
import '../../widgets/consult/symptom_checker_view.dart';

class ConsultScreen extends StatefulWidget {
  const ConsultScreen({super.key});

  @override
  State<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends State<ConsultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
              tabs: const [
                Tab(
                  height: 40,
                  child: Center(child: Text('Find Doctor')),
                ),
                Tab(
                  height: 40,
                  child: Center(child: Text('Symptom Check')),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DoctorBookingView(),
              const SymptomCheckerView(),
            ],
          ),
        ),
      ],
    );
  }
}
