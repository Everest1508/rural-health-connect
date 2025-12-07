enum NotificationType {
  appointment,
  appointmentReminder,
  appointmentCancelled,
  appointmentConfirmed,
  prescription,
  labResult,
  vaccination,
  info,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String timeAgo;
  final DateTime createdAt;
  final int? relatedAppointmentId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.timeAgo,
    required this.createdAt,
    this.relatedAppointmentId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Parse notification type
    NotificationType notificationType = NotificationType.info;
    final typeStr = json['notification_type'] ?? 'info';
    switch (typeStr) {
      case 'appointment':
        notificationType = NotificationType.appointment;
        break;
      case 'appointment_reminder':
        notificationType = NotificationType.appointmentReminder;
        break;
      case 'appointment_cancelled':
        notificationType = NotificationType.appointmentCancelled;
        break;
      case 'appointment_confirmed':
        notificationType = NotificationType.appointmentConfirmed;
        break;
      case 'prescription':
        notificationType = NotificationType.prescription;
        break;
      case 'lab_result':
        notificationType = NotificationType.labResult;
        break;
      case 'vaccination':
        notificationType = NotificationType.vaccination;
        break;
      case 'system':
        notificationType = NotificationType.system;
        break;
      default:
        notificationType = NotificationType.info;
    }

    // Parse created_at
    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at']);
      } catch (e) {
        createdAt = DateTime.now();
      }
    }

    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: notificationType,
      isRead: json['is_read'] ?? false,
      timeAgo: json['time_ago'] ?? '',
      createdAt: createdAt,
      relatedAppointmentId: json['related_appointment_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': type.toString().split('.').last,
      'is_read': isRead,
      'time_ago': timeAgo,
      'created_at': createdAt.toIso8601String(),
      'related_appointment_id': relatedAppointmentId,
    };
  }
}

