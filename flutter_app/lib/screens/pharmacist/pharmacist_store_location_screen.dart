import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../core/api/pharmacy_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/pharmacist_model.dart';
import '../../l10n/app_localizations.dart';

class PharmacistStoreLocationScreen extends StatefulWidget {
  const PharmacistStoreLocationScreen({super.key});

  @override
  State<PharmacistStoreLocationScreen> createState() => _PharmacistStoreLocationScreenState();
}

class _PharmacistStoreLocationScreenState extends State<PharmacistStoreLocationScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _phoneController = TextEditingController();

  Pharmacist? _pharmacist;
  bool _isLoading = true;
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadPharmacistProfile();
  }

  Future<void> _loadPharmacistProfile() async {
    setState(() => _isLoading = true);
    try {
      final pharmacist = await _pharmacyService.getPharmacistProfile();
      if (pharmacist != null) {
        setState(() {
          _pharmacist = pharmacist;
          _storeNameController.text = pharmacist.storeName;
          _storeAddressController.text = pharmacist.storeAddress;
          _phoneController.text = pharmacist.phone ?? '';
          _latitude = pharmacist.latitude;
          _longitude = pharmacist.longitude;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation(showError: true);
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        // Get address from coordinates
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (address != null) {
          _storeAddressController.text = address;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set store location')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _pharmacyService.updatePharmacistProfile(
        storeName: _storeNameController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPharmacistProfile();
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storeLocation),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.storeInformation,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        labelText: '${l10n.storeName} *',
                        hintText: 'Enter store name',
                        prefixIcon: const Icon(Icons.store),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Store name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _storeAddressController,
                      decoration: InputDecoration(
                        labelText: '${l10n.storeAddress} *',
                        hintText: 'Enter store address',
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Store address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (Optional)',
                        hintText: 'Enter phone number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.location,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_latitude != null && _longitude != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Location Set',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Latitude: ${_latitude!.toStringAsFixed(6)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                'Longitude: ${_longitude!.toStringAsFixed(6)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: Text(l10n.useCurrentLocation),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}



