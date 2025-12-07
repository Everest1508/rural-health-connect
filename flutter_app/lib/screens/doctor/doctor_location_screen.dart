import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../core/api/doctor_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../../models/doctor_model.dart';

class DoctorLocationScreen extends StatefulWidget {
  const DoctorLocationScreen({super.key});

  @override
  State<DoctorLocationScreen> createState() => _DoctorLocationScreenState();
}

class _DoctorLocationScreenState extends State<DoctorLocationScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _addressController = TextEditingController();
  
  Doctor? _doctorProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorProfile() async {
    setState(() => _isLoading = true);
    try {
      final doctor = await _doctorService.getDoctorProfile();
      if (doctor != null && mounted) {
        setState(() {
          _doctorProfile = doctor;
          _addressController.text = doctor.clinicAddress ?? '';
          _latitude = doctor.latitude;
          _longitude = doctor.longitude;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
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

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation(showError: true);
      if (position != null && mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        // Try to get address from coordinates
        try {
          final address = await LocationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (address != null && address.isNotEmpty && mounted) {
            _addressController.text = address;
          }
        } catch (e) {
          print('Error getting address: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${ErrorHandler.getErrorMessage(e)}'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    }
  }

  Future<void> _saveLocation() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter clinic address'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please get your current location'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Round coordinates to 6 decimal places
      final roundedLat = double.parse(_latitude!.toStringAsFixed(6));
      final roundedLng = double.parse(_longitude!.toStringAsFixed(6));

      final success = await _doctorService.updateDoctorProfile(
        clinicAddress: _addressController.text.trim(),
        latitude: roundedLat,
        longitude: roundedLng,
      );

      if (success && mounted) {
        await _loadDoctorProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        throw Exception('Failed to save location');
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clinic Location')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Location'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add your clinic location to help patients find directions for in-person appointments.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Clinic Address',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your clinic address...',
                filled: true,
                fillColor: theme.cardColor,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location Coordinates',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _latitude != null
                              ? _latitude!.toStringAsFixed(6)
                              : 'Not set',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Longitude',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _longitude != null
                              ? _longitude!.toStringAsFixed(6)
                              : 'Not set',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Get Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveLocation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Location'),
              ),
            ),
            if (_doctorProfile != null &&
                _doctorProfile!.clinicAddress != null &&
                _doctorProfile!.clinicAddress!.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Saved',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _doctorProfile!.clinicAddress!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

