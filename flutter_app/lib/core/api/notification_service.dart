import 'api_client.dart';
import '../../models/notification_model.dart';

class NotificationService {
  final ApiClient _api = ApiClient();
  
  /// Get all notifications
  Future<List<AppNotification>> getNotifications({
    bool? isRead,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['read'] = isRead.toString();
      if (type != null) queryParams['type'] = type;
      
      final response = await _api.get('/notifications/', queryParameters: queryParams);
      
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
        return data.map((json) => AppNotification.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.get('/notifications/unread-count/');
      if (response.statusCode == 200) {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }
  
  /// Mark notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _api.put('/notifications/$notificationId/', data: {
        'is_read': true,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _api.post('/notifications/mark-all-read/');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }
  
  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _api.delete('/notifications/$notificationId/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}

