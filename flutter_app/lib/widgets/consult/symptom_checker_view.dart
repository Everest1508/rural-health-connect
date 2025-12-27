import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/api/symptom_checker_service.dart';
import '../../core/services/api_config_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_handler.dart';
import '../../l10n/app_localizations.dart';

class SymptomCheckerView extends StatefulWidget {
  const SymptomCheckerView({super.key});

  @override
  State<SymptomCheckerView> createState() => _SymptomCheckerViewState();
}

class _SymptomCheckerViewState extends State<SymptomCheckerView> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _customSymptomController = TextEditingController();
  final SymptomCheckerService _symptomCheckerService = SymptomCheckerService();
  final List<String> _selectedSymptoms = [];
  final List<String> _commonSymptoms = [
    'Fever',
    'Headache',
    'Cough',
    'Fatigue',
    'Nausea',
    'Body Pain',
    'Sore Throat',
    'Runny Nose',
    'Dizziness',
    'Chest Pain',
  ];
  bool _isAnalyzing = false;
  String? _analysisResult;
  
  @override
  void dispose() {
    _symptomsController.dispose();
    _customSymptomController.dispose();
    super.dispose();
  }
  
  void _addSymptom(String symptom) {
    if (!_selectedSymptoms.contains(symptom)) {
      setState(() {
        _selectedSymptoms.add(symptom);
      });
    }
  }
  
  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }
  
  void _addCustomSymptom() {
    final customSymptom = _customSymptomController.text.trim();
    if (customSymptom.isNotEmpty && !_selectedSymptoms.contains(customSymptom)) {
      setState(() {
        _selectedSymptoms.add(customSymptom);
        _customSymptomController.clear();
      });
    }
  }
  
  Future<void> _analyzeSymptoms() async {
    // Combine selected symptoms and text description
    final symptomList = _selectedSymptoms.join(', ');
    final description = _symptomsController.text.trim();
    
    String fullSymptoms = '';
    if (symptomList.isNotEmpty && description.isNotEmpty) {
      fullSymptoms = '$symptomList. $description';
    } else if (symptomList.isNotEmpty) {
      fullSymptoms = symptomList;
    } else if (description.isNotEmpty) {
      fullSymptoms = description;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your symptoms or select from common symptoms'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });
    
    try {
      // Check if Groq API key is configured
      final groqKey = await ApiConfigService.getGroqApiKey();
      if (groqKey == null || groqKey.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Groq API key is not configured. Please add it in settings (click the settings icon).'),
              backgroundColor: AppTheme.destructiveColor,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      final result = await _symptomCheckerService.analyzeSymptoms(fullSymptoms);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          
          // Safely check result
          if (result.containsKey('success') && result['success'] == true) {
            final analysis = result['analysis'];
            if (analysis != null && analysis.toString().isNotEmpty) {
              _analysisResult = analysis.toString();
            } else {
              _analysisResult = 'Error: Analysis result is empty. Please try again.';
            }
          } else {
            final error = result['error'] ?? 'Something went wrong. Please try again.';
            _analysisResult = 'Error: $error';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = 'Error: ${ErrorHandler.getErrorMessage(e)}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Symptom Checker',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe your symptoms and get preliminary health insights',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
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
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is not a substitute for professional medical advice',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Describe Your Symptoms',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _symptomsController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l10n.enterYourSymptoms,
              filled: true,
              fillColor: theme.cardColor,
            ),
          ),
          const SizedBox(height: 24),
          // Selected Symptoms
          if (_selectedSymptoms.isNotEmpty) ...[
            Text(
              'Selected Symptoms',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSymptoms.map((symptom) {
                return Chip(
                  label: Text(symptom),
                  onDeleted: () => _removeSymptom(symptom),
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Common Symptoms
          Text(
            'Common Symptoms',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return _SymptomChip(
                label: symptom,
                icon: _getSymptomIcon(symptom),
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    _removeSymptom(symptom);
                  } else {
                    _addSymptom(symptom);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Add Custom Symptom
          Text(
            'Add Custom Symptom',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customSymptomController,
                  decoration: InputDecoration(
                    hintText: 'Enter custom symptom...',
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  onSubmitted: (_) => _addCustomSymptom(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addCustomSymptom,
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeSymptoms,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Analyze Symptoms'),
            ),
          ),
          // Analysis Result
          if (_analysisResult != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Analysis Result',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Check if result starts with "Error:" to determine if it's an error or markdown
                  _analysisResult!.startsWith('Error:')
                      ? Text(
                          _analysisResult!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.destructiveColor,
                          ),
                        )
                      : MarkdownBody(
                          data: _analysisResult!,
                          shrinkWrap: true,
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium,
                            pPadding: const EdgeInsets.only(bottom: 8),
                            h1: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                            h2: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            h2Padding: const EdgeInsets.only(top: 12, bottom: 6),
                            h3: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            h3Padding: const EdgeInsets.only(top: 10, bottom: 4),
                            strong: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            em: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            listBullet: theme.textTheme.bodyMedium,
                            listIndent: 16,
                            code: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              backgroundColor: theme.scaffoldBackgroundColor,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.2),
                              ),
                            ),
                            codeblockPadding: const EdgeInsets.all(8),
                            blockquote: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                              fontStyle: FontStyle.italic,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 4,
                                ),
                              ),
                            ),
                            blockquotePadding: const EdgeInsets.all(12),
                          ),
                        ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  IconData _getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'fever':
        return Icons.thermostat;
      case 'headache':
        return Icons.psychology;
      case 'cough':
        return Icons.air;
      case 'fatigue':
        return Icons.bedtime;
      case 'nausea':
        return Icons.sick;
      case 'body pain':
        return Icons.accessibility_new;
      case 'sore throat':
        return Icons.medical_services;
      case 'runny nose':
        return Icons.water_drop;
      case 'dizziness':
        return Icons.rotate_right;
      case 'chest pain':
        return Icons.favorite;
      default:
        return Icons.medical_information;
    }
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SymptomChip({
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : theme.dividerColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
