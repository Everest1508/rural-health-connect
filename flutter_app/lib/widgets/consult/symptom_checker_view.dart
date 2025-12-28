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
  bool _isAnalyzing = false;
  String? _analysisResult;
  
  List<String> _getCommonSymptoms(AppLocalizations l10n) {
    return [
      l10n.fever,
      l10n.headache,
      l10n.cough,
      l10n.fatigue,
      l10n.nausea,
      l10n.bodyPain,
      l10n.soreThroat,
      l10n.runnyNose,
      l10n.dizziness,
      l10n.chestPain,
    ];
  }
  
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseDescribeSymptoms),
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.groqApiKeyNotConfigured),
              backgroundColor: AppTheme.destructiveColor,
              duration: const Duration(seconds: 5),
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
            l10n.symptomChecker,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.describeSymptomsAndGetInsights,
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
                    l10n.notSubstituteForMedicalAdvice,
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
              l10n.selectedSymptoms,
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
            l10n.commonSymptoms,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getCommonSymptoms(l10n).map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return _SymptomChip(
                label: symptom,
                icon: _getSymptomIcon(symptom, l10n),
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
            l10n.addCustomSymptom,
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
                    hintText: l10n.enterCustomSymptom,
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
                  : Text(l10n.analyzeSymptoms),
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
                        l10n.analysisResult,
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
  
  IconData _getSymptomIcon(String symptom, AppLocalizations l10n) {
    // Map localized symptoms to icons by comparing with known localized strings
    if (symptom == l10n.fever) {
      return Icons.thermostat;
    } else if (symptom == l10n.headache) {
      return Icons.psychology;
    } else if (symptom == l10n.cough) {
      return Icons.air;
    } else if (symptom == l10n.fatigue) {
      return Icons.bedtime;
    } else if (symptom == l10n.nausea) {
      return Icons.sick;
    } else if (symptom == l10n.bodyPain) {
      return Icons.accessibility_new;
    } else if (symptom == l10n.soreThroat) {
      return Icons.medical_services;
    } else if (symptom == l10n.runnyNose) {
      return Icons.water_drop;
    } else if (symptom == l10n.dizziness) {
      return Icons.rotate_right;
    } else if (symptom == l10n.chestPain) {
      return Icons.favorite;
    } else {
      // For custom symptoms, try to match by English name as fallback
      final lowerSymptom = symptom.toLowerCase();
      if (lowerSymptom.contains('fever') || lowerSymptom.contains('बुखार') || lowerSymptom.contains('ताप')) {
        return Icons.thermostat;
      } else if (lowerSymptom.contains('headache') || lowerSymptom.contains('सिरदर्द') || lowerSymptom.contains('डोकेदुखी')) {
        return Icons.psychology;
      } else if (lowerSymptom.contains('cough') || lowerSymptom.contains('खांसी') || lowerSymptom.contains('खोकला')) {
        return Icons.air;
      } else if (lowerSymptom.contains('chest') || lowerSymptom.contains('छाती') || lowerSymptom.contains('छातीत')) {
        return Icons.favorite;
      }
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
