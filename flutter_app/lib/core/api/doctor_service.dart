import 'api_client.dart';
import '../../models/doctor_model.dart';

class DoctorService {
  final ApiClient _api = ApiClient();
  
  Future<List<Doctor>> getDoctors({
    String? specialty,
    bool? available,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (specialty != null) queryParams['specialty'] = specialty;
      if (available != null) queryParams['available'] = available.toString();
      
      final response = await _api.get('/appointments/doctors/', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        // Handle paginated response or direct list
        final responseData = response.data;
        List<dynamic> data;
        if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'];
        } else if (responseData is List) {
          data = responseData;
        } else {
          print('⚠️ DoctorService: Unexpected response format: ${responseData.runtimeType}');
          print('Response data: $responseData');
          data = [];
        }
        
        final doctors = data.map((json) {
          try {
            return Doctor.fromJson(json);
          } catch (e) {
            print('⚠️ Error parsing doctor JSON: $e');
            print('Doctor JSON: $json');
            rethrow;
          }
        }).toList();
        
        print('✅ DoctorService: Loaded ${doctors.length} doctors');
        return doctors;
      } else {
        print('⚠️ DoctorService: Unexpected status code: ${response.statusCode}');
        print('Response: ${response.data}');
      }
      return [];
    } catch (e) {
      print('❌ DoctorService Error: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }
  
  Future<Doctor?> getDoctor(int id) async {
    try {
      final response = await _api.get('/appointments/doctors/$id/');
      if (response.statusCode == 200) {
        return Doctor.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<List<String>> getAvailability(int doctorId, String date) async {
    try {
      final response = await _api.get(
        '/appointments/doctors/$doctorId/availability/',
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200) {
        return List<String>.from(response.data['available_slots'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getAvailabilityWithInfo(int doctorId, String date) async {
    try {
      final response = await _api.get(
        '/appointments/doctors/$doctorId/availability/',
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'slots': List<String>.from(data['available_slots'] ?? []),
          'schedule': data['schedule'],
          'message': data['message'],
        };
      }
      return {'slots': [], 'schedule': null, 'message': null};
    } catch (e) {
      return {'slots': [], 'schedule': null, 'message': null};
    }
  }

  Future<Doctor?> getDoctorProfile() async {
    try {
      final response = await _api.get('/appointments/doctors/profile/');
      if (response.statusCode == 200) {
        return Doctor.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ DoctorService.getDoctorProfile Error: $e');
      return null;
    }
  }

  Future<bool> updateDoctorProfile({
    String? clinicAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (clinicAddress != null) data['clinic_address'] = clinicAddress;
      if (latitude != null) data['latitude'] = latitude.toString();
      if (longitude != null) data['longitude'] = longitude.toString();

      final response = await _api.patch('/appointments/doctors/profile/', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ DoctorService.updateDoctorProfile Error: $e');
      return false;
    }
  }
}

