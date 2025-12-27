import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../models/health_record_model.dart';

class HealthRecordService {
  final ApiClient _api = ApiClient();

  /// Get health records for the current user
  /// Optionally filter by appointment ID
  Future<List<HealthRecord>> getHealthRecords({
    String? appointmentId,
    String? patientId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (appointmentId != null) {
        queryParams['appointment'] = appointmentId;
      }
      if (patientId != null) {
        queryParams['patient'] = patientId;
      }

      final response = await _api.get(
        '/appointments/health-records/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          data = [];
        }
        return data.map((json) => HealthRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Create a new health record
  /// Returns a map with 'success' boolean and optional 'record' or 'error'
  Future<Map<String, dynamic>> createHealthRecord({
    String? appointmentId,
    required String date,
    required String title,
    required String description,
    String? filePath,
  }) async {
    try {
      // If file is provided, use multipart/form-data
      if (filePath != null) {
        final formData = FormData.fromMap({
          'date': date,
          'title': title,
          'description': description,
          if (appointmentId != null) 'appointment': appointmentId,
          'attachment': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split('/').last,
          ),
        });

        final response = await _api.post(
          '/appointments/health-records/',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        // If status is 201, the record was created successfully
        if (response.statusCode == 201) {
          try {
            final record = HealthRecord.fromJson(response.data);
            return {'success': true, 'record': record};
          } catch (parseError) {
            print('Error parsing health record response: $parseError');
            print('Response data: ${response.data}');
            return {'success': true, 'record': null};
          }
        }
        
        return {
          'success': false,
          'error': 'Failed to create health record. Status: ${response.statusCode}'
        };
      } else {
        // No file, use regular JSON
        final data = <String, dynamic>{
          'date': date,
          'title': title,
          'description': description,
        };
        if (appointmentId != null) {
          data['appointment'] = appointmentId;
        }

        final response = await _api.post(
          '/appointments/health-records/',
          data: data,
        );

        // If status is 201, the record was created successfully
        if (response.statusCode == 201) {
          try {
            final record = HealthRecord.fromJson(response.data);
            return {'success': true, 'record': record};
          } catch (parseError) {
            print('Error parsing health record response: $parseError');
            print('Response data: ${response.data}');
            return {'success': true, 'record': null};
          }
        }
        
        return {
          'success': false,
          'error': 'Failed to create health record. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error creating health record: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }

  /// Get a specific health record by ID
  Future<HealthRecord?> getHealthRecord(String id) async {
    try {
      final response = await _api.get('/appointments/health-records/$id/');
      if (response.statusCode == 200) {
        return HealthRecord.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update a health record
  Future<HealthRecord?> updateHealthRecord(
    String id, {
    String? date,
    String? title,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (date != null) data['date'] = date;
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;

      final response = await _api.patch(
        '/appointments/health-records/$id/',
        data: data,
      );

      if (response.statusCode == 200) {
        return HealthRecord.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete a health record
  Future<bool> deleteHealthRecord(String id) async {
    try {
      final response = await _api.delete('/appointments/health-records/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

