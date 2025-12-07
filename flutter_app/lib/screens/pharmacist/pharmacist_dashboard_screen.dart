import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../core/api/pharmacy_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import 'pharmacist_orders_screen.dart';

class PharmacistDashboardScreen extends StatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  State<PharmacistDashboardScreen> createState() => _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends State<PharmacistDashboardScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  List<Order> _orders = [];
  bool _isLoading = true;
  int _pendingCount = 0;
  int _todayCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _pharmacyService.getOrders();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _orders = orders;
      _totalCount = orders.length;
      _pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
      _todayCount = orders.where((o) {
        final orderDate = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
        return orderDate.year == today.year &&
            orderDate.month == today.month &&
            orderDate.day == today.day;
      }).length;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          theme,
                          'Total Orders',
                          _totalCount.toString(),
                          BoxIcons.bx_package,
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          theme,
                          'Pending',
                          _pendingCount.toString(),
                          BoxIcons.bx_time,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          theme,
                          'Today',
                          _todayCount.toString(),
                          BoxIcons.bx_calendar,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          theme,
                          'Ready',
                          _orders.where((o) => o.status == OrderStatus.ready).length.toString(),
                          BoxIcons.bx_check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Orders',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to orders screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PharmacistOrdersScreen(),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_orders.isEmpty)
                    _buildEmptyState(context, theme)
                  else
                    ..._orders.take(5).map((order) => _buildOrderCard(context, theme, order)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            BoxIcons.bx_package,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Orders from patients will appear here',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    ThemeData theme,
    Order order,
  ) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showOrderDetails(context, theme, order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: order.prescriptionImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          order.prescriptionImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(BoxIcons.bx_file, color: statusColor),
                        ),
                      )
                    : Icon(BoxIcons.bx_file, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.patientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  void _showOrderDetails(BuildContext context, ThemeData theme, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.prescriptionImageUrl != null) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.prescriptionImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('Patient', order.patientName, theme),
              _buildDetailRow('Status', order.statusLabel, theme),
              _buildDetailRow('Delivery Address', order.deliveryAddress, theme),
              if (order.prescriptionText.isNotEmpty)
                _buildDetailRow('Prescription', order.prescriptionText, theme),
              _buildDetailRow(
                'Order Date',
                DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                theme,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}



