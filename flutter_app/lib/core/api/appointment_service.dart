import 'package:dio/dio.dart';
import 'api_client.dart';
import '../../models/appointment_model.dart';

class AppointmentService {
  final ApiClient _api = ApiClient();
  
  Future<List<Appointment>> getAppointments({
    String? status,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      
      final response = await _api.get('/appointments/', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Handle paginated response or direct list
        final responseData = response.data;
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          data = [];
        }
        return data.map((json) => Appointment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<Appointment?> createAppointment({
    required int doctorId,
    required String appointmentType,
    required String scheduledDate,
    required String scheduledTime,
    String? reason,
  }) async {
    final response = await _api.post('/appointments/', data: {
      'doctor': doctorId,
      'appointment_type': appointmentType,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'reason': reason ?? '',
    });
    
    if (response.statusCode == 201) {
      return Appointment.fromJson(response.data);
    }
    return null;
  }
  
  Future<Appointment?> getAppointment(int id) async {
    try {
      final response = await _api.get('/appointments/$id/');
      if (response.statusCode == 200) {
        return Appointment.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateAppointment(int id, {
    String? scheduledDate,
    String? scheduledTime,
    String? status,
    String? reason,
    String? notes,
    String? prescription,
  }) async {
    final data = <String, dynamic>{};
    if (scheduledDate != null) data['scheduled_date'] = scheduledDate;
    if (scheduledTime != null) data['scheduled_time'] = scheduledTime;
    if (status != null) data['status'] = status;
    if (reason != null) data['reason'] = reason;
    if (notes != null) data['notes'] = notes;
    if (prescription != null) data['prescription'] = prescription;
    
    try {
      final response = await _api.put('/appointments/$id/', data: data);
      if (response.statusCode == 200) {
        return true;
      }
      // If status code is not 200, create a DioException so ErrorHandler can process it
      throw DioException(
        requestOptions: RequestOptions(path: '/appointments/$id/'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      // Re-throw DioException so ErrorHandler can process it
      rethrow;
    } catch (e) {
      // Wrap other exceptions in DioException
      throw DioException(
        requestOptions: RequestOptions(path: '/appointments/$id/'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }
  
  Future<bool> cancelAppointment(int id) async {
    try {
      final response = await _api.delete('/appointments/$id/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

