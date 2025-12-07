import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../core/api/pharmacy_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/error_handler.dart';
import '../../models/prescription_model.dart';
import 'order_pharmacy_screen.dart';

class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Prescription> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => _isLoading = true);
    try {
      final prescriptions = await _pharmacyService.getPrescriptions();
      setState(() {
        _prescriptions = prescriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPrescription() async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    XFile? selectedImage;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Prescription'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    hintText: 'e.g., Doctor Visit - Dec 2025',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Additional information',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                if (selectedImage != null)
                  Container(
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      setDialogState(() {
                        selectedImage = image;
                      });
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(selectedImage == null ? 'Select Image' : 'Change Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        await _pharmacyService.createPrescription(
          title: titleController.text.trim(),
          imagePath: selectedImage?.path,
          notes: notesController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription uploaded successfully')),
          );
          _loadPrescriptions();
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
  }

  Future<void> _deletePrescription(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: const Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _pharmacyService.deletePrescription(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription deleted')),
          );
          _loadPrescriptions();
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPrescriptions,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _prescriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          BoxIcons.bx_file_blank,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No prescriptions yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your first prescription',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = _prescriptions[index];
                      return _buildPrescriptionCard(context, theme, prescription);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPrescription,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    ThemeData theme,
    Prescription prescription,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          try {
            final position = await LocationService.getCurrentLocation(showError: true);
            if (position != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderPharmacyScreen(
                    latitude: position.latitude,
                    longitude: position.longitude,
                    prescription: prescription,
                  ),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceFirst('Exception: ', '')),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: prescription.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          prescription.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(BoxIcons.bx_file, color: theme.colorScheme.primary),
                        ),
                      )
                    : Icon(BoxIcons.bx_file, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription.title.isNotEmpty
                          ? prescription.title
                          : 'Prescription',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(prescription.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (prescription.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        prescription.notes,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'order',
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart),
                        SizedBox(width: 8),
                        Text('Order'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'order') {
                    LocationService.getCurrentLocation(showError: true).then((position) {
                      if (position != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPharmacyScreen(
                              latitude: position.latitude,
                              longitude: position.longitude,
                              prescription: prescription,
                            ),
                          ),
                        );
                      }
                    }).catchError((e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    });
                  } else if (value == 'delete') {
                    _deletePrescription(prescription.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

