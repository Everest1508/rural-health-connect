import 'package:dio/dio.dart';
import 'api_client.dart';

class ScheduleService {
  final ApiClient _api = ApiClient();
  
  /// Get doctor's schedule
  Future<List<Map<String, dynamic>>> getSchedule() async {
    try {
      final response = await _api.get('/appointments/doctors/schedule/');
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
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }
  
  /// Create or update schedule entry
  Future<Map<String, dynamic>?> saveSchedule({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required bool isAvailable,
    int? scheduleId,
  }) async {
    try {
      final data = {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
      };
      
      Response response;
      if (scheduleId != null) {
        // Update existing
        response = await _api.put('/appointments/doctors/schedule/$scheduleId/', data: data);
      } else {
        // Create new
        response = await _api.post('/appointments/doctors/schedule/', data: data);
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error saving schedule: $e');
      return null;
    }
  }
  
  /// Delete schedule entry
  Future<bool> deleteSchedule(int scheduleId) async {
    try {
      final response = await _api.delete('/appointments/doctors/schedule/$scheduleId/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }
}

