import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../core/utils/error_handler.dart';

class SymptomCheckerService {
  final ApiClient _api = ApiClient();
  
  /// Analyze symptoms using Groq API via backend
  /// The Groq API key is configured on the server side
  Future<Map<String, dynamic>> analyzeSymptoms(String symptoms) async {
    try {
      if (symptoms.trim().isEmpty) {
        return {
          'success': false,
          'error': 'Please describe your symptoms or select from common symptoms.'
        };
      }
      
      // Send only symptoms - Groq API key is handled by the backend
      final response = await _api.post('/appointments/symptom-checker/', data: {
        'symptoms': symptoms.trim(),
      });
      
      // Debug logging
      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Safely extract data from response
        final data = response.data;
        print('Data type check: ${data is Map}');
        
        if (data is Map) {
          final analysis = data['analysis'];
          final model = data['model'] ?? 'unknown';
          
          print('Analysis value: $analysis');
          print('Analysis type: ${analysis.runtimeType}');
          
          if (analysis != null && analysis.toString().isNotEmpty) {
            return {
              'success': true,
              'analysis': analysis.toString(),
              'model': model.toString(),
            };
          } else {
            return {
              'success': false,
              'error': 'Analysis result is empty. Please try again.',
            };
          }
        } else {
          return {
            'success': false,
            'error': 'Unexpected response format from server. Received: ${data.runtimeType}',
          };
        }
      } else {
        // Extract error message from response
        String errorMsg = 'Failed to analyze symptoms';
        if (response.data is Map) {
          errorMsg = response.data['error'] ?? errorMsg;
        }
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } on DioException catch (e) {
      // Handle DioException specifically to get backend error message
      String errorMsg = 'Network error. Please check your connection and try again.';
      
      if (e.response != null) {
        // Backend returned an error response
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          errorMsg = data['error'].toString();
        } else {
          errorMsg = ErrorHandler.getErrorMessage(e);
        }
      } else {
        errorMsg = ErrorHandler.getErrorMessage(e);
      }
      
      return {
        'success': false,
        'error': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'error': ErrorHandler.getErrorMessage(e),
      };
    }
  }
}

