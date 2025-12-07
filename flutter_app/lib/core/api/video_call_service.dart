import 'api_client.dart';

class VideoCallService {
  final ApiClient _api = ApiClient();
  
  Future<Map<String, dynamic>?> createRoom(int appointmentId) async {
    try {
      final response = await _api.post('/video-calls/create-room/', data: {
        'appointment': appointmentId,
      });
      
      if (response.statusCode == 201) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getRoomByAppointment(int appointmentId) async {
    try {
      final response = await _api.get('/video-calls/appointment/$appointmentId/room/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getRoomDetails(String roomId) async {
    try {
      final response = await _api.get('/video-calls/room/$roomId/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> joinRoom(String roomId) async {
    try {
      final response = await _api.post('/video-calls/room/$roomId/join/');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> leaveRoom(String roomId) async {
    try {
      final response = await _api.post('/video-calls/room/$roomId/leave/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

