import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../core/api/pharmacy_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/pharmacist_model.dart';
import '../../models/prescription_model.dart';
import '../../models/order_model.dart';
import '../../models/appointment_model.dart';

class OrderPharmacyScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Prescription? prescription;
  final Appointment? appointment;

  const OrderPharmacyScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.prescription,
    this.appointment,
  });

  @override
  State<OrderPharmacyScreen> createState() => _OrderPharmacyScreenState();
}

class _OrderPharmacyScreenState extends State<OrderPharmacyScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Pharmacist> _pharmacists = [];
  Pharmacist? _selectedPharmacist;
  bool _isLoading = true;
  bool _isPlacingOrder = false;
  String? _deliveryAddress;

  @override
  void initState() {
    super.initState();
    _loadNearestPharmacists();
    _loadAddress();
    if (widget.prescription != null) {
      _prescriptionController.text = widget.prescription!.notes;
    } else if (widget.appointment != null && widget.appointment!.prescription != null) {
      _prescriptionController.text = widget.appointment!.prescription!;
    }
  }

  Future<void> _loadAddress() async {
    try {
      final address = await LocationService.getAddressFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (address != null) {
        setState(() {
          _deliveryAddress = address;
          _addressController.text = address;
        });
      }
    } catch (e) {
      print('Error loading address: $e');
    }
  }

  Future<void> _loadNearestPharmacists() async {
    setState(() => _isLoading = true);
    try {
      final pharmacists = await _pharmacyService.getNearestPharmacists(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      setState(() {
        _pharmacists = pharmacists;
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

  Future<void> _placeOrder() async {
    if (_selectedPharmacist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pharmacist')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    if (_prescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter prescription details')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final order = await _pharmacyService.createOrder(
        pharmacistId: _selectedPharmacist!.id,
        prescriptionId: widget.prescription?.id,
        appointmentId: widget.appointment != null ? int.parse(widget.appointment!.id) : null,
        prescriptionText: _prescriptionController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        latitude: widget.latitude,
        longitude: widget.longitude,
        notes: _notesController.text.trim(),
      );

      if (order != null && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order from Pharmacy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pharmacist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pharmacists.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        BoxIcons.bx_store,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pharmacists found nearby',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._pharmacists.map((pharmacist) => _buildPharmacistCard(
                    context,
                    theme,
                    pharmacist,
                  )),
            const SizedBox(height: 24),
            Text(
              'Delivery Address',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter delivery address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Prescription Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prescriptionController,
              decoration: InputDecoration(
                hintText: 'Enter prescription details or medicines needed',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Additional notes (optional)',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacistCard(
    BuildContext context,
    ThemeData theme,
    Pharmacist pharmacist,
  ) {
    final isSelected = _selectedPharmacist?.id == pharmacist.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPharmacist = pharmacist;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  BoxIcons.bx_store,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacist.storeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pharmacist.storeAddress,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pharmacist.distanceKm != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pharmacist.distanceKm} km away',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

