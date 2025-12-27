import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/services/api_config_service.dart';
import '../../core/theme/app_theme.dart';

class ApiConfigButton extends StatefulWidget {
  const ApiConfigButton({super.key});

  @override
  State<ApiConfigButton> createState() => _ApiConfigButtonState();
}

class _ApiConfigButtonState extends State<ApiConfigButton> {
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  Future<void> _loadCurrentUrl() async {
    final url = await ApiConfigService.getBaseUrl();
    if (mounted) {
      setState(() {
        _currentUrl = url;
      });
    }
  }

  Future<void> _showConfigDialog() async {
    final currentUrl = await ApiConfigService.getBaseUrl();
    final currentGroqKey = await ApiConfigService.getGroqApiKey();
    final urlController = TextEditingController(text: currentUrl);
    final groqKeyController = TextEditingController(text: currentGroqKey ?? '');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Base URL Section
              const Text(
                'API Base URL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter the API base URL (e.g., https://swasthsetu.pythonanywhere.com/api)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'https://swasthsetu.pythonanywhere.com/api',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: $_currentUrl',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Groq API Key Section
              const Text(
                'Groq API Key',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Required for symptom checker AI analysis',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: groqKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Groq API Key',
                  hintText: 'gsk_...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ApiConfigService.resetToDefault();
              final defaultUrl = await ApiConfigService.getBaseUrl();
              await ApiClient().updateBaseUrl(defaultUrl);
              if (mounted) {
                Navigator.pop(context);
                _loadCurrentUrl();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reset to default: $defaultUrl'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Reset URL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = urlController.text.trim();
              final newGroqKey = groqKeyController.text.trim();
              
              if (newUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL cannot be empty'),
                    backgroundColor: AppTheme.destructiveColor,
                  ),
                );
                return;
              }
              
              try {
                await ApiConfigService.setBaseUrl(newUrl);
                await ApiClient().updateBaseUrl(newUrl);
                
                if (newGroqKey.isNotEmpty) {
                  await ApiConfigService.setGroqApiKey(newGroqKey);
                } else {
                  await ApiConfigService.removeGroqApiKey();
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  _loadCurrentUrl();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration saved successfully'),
                      backgroundColor: AppTheme.successColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.destructiveColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _showConfigDialog,
      mini: true,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
      foregroundColor: Colors.white,
      child: const Icon(Icons.settings, size: 20),
      heroTag: 'api_config_button', // Important: unique tag for each FAB
    );
  }
}

