import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../core/api/pharmacy_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../l10n/app_localizations.dart';

class PharmacistOrdersScreen extends StatefulWidget {
  const PharmacistOrdersScreen({super.key});

  @override
  State<PharmacistOrdersScreen> createState() => _PharmacistOrdersScreenState();
}

class _PharmacistOrdersScreenState extends State<PharmacistOrdersScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  List<Order> _orders = [];
  bool _isLoading = true;
  OrderStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _pharmacyService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
          ),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      await _pharmacyService.updateOrderStatus(order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
          ),
        );
      }
    }
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(context, theme, null, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, theme, OrderStatus.pending, 'Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, theme, OrderStatus.confirmed, 'Confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, theme, OrderStatus.preparing, 'Preparing'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, theme, OrderStatus.ready, 'Ready'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, theme, OrderStatus.completed, 'Completed'),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                BoxIcons.bx_package,
                                size: 64,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders found',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return _buildOrderCard(context, theme, order);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    OrderStatus? status,
    String label,
  ) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? status : null;
        });
      },
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
      child: ExpansionTile(
        leading: Container(
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
        title: Text(
          order.patientName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
        ),
        trailing: Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.prescriptionImageUrl != null) ...[
                  Container(
                    height: 150,
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
                _buildDetailRow('Delivery Address', order.deliveryAddress, theme),
                if (order.prescriptionText.isNotEmpty)
                  _buildDetailRow('Prescription', order.prescriptionText, theme),
                if (order.notes.isNotEmpty)
                  _buildDetailRow('Notes', order.notes, theme),
                const SizedBox(height: 16),
                // Status update buttons
                if (order.status != OrderStatus.completed &&
                    order.status != OrderStatus.cancelled)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (order.status == OrderStatus.pending)
                        ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                            order,
                            OrderStatus.confirmed,
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Confirm'),
                        ),
                      if (order.status == OrderStatus.confirmed)
                        ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                            order,
                            OrderStatus.preparing,
                          ),
                          icon: const Icon(Icons.build, size: 18),
                          label: const Text('Start Preparing'),
                        ),
                      if (order.status == OrderStatus.preparing)
                        ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                            order,
                            OrderStatus.ready,
                          ),
                          icon: const Icon(Icons.local_pharmacy, size: 18),
                          label: const Text('Mark Ready'),
                        ),
                      if (order.status == OrderStatus.ready)
                        ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                            order,
                            OrderStatus.completed,
                          ),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
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



