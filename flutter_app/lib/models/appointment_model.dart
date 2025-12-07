enum AppointmentType { video, inPerson }

enum AppointmentStatus { scheduled, confirmed, inProgress, completed, cancelled }

class Appointment {
  final String id;
  final String doctorName;
  final String? patientName;
  final String specialty;
  final String date;
  final String rawDate; // Original date in YYYY-MM-DD format for filtering
  final String time;
  final AppointmentType type;
  final AppointmentStatus status;
  final int? doctorId;
  final String? googleMeetLink; // Google Meet link for video appointments
  final String? notes; // Notes added by patient
  final String? prescription; // Prescription added by doctor
  final String? reason; // Reason for appointment

  Appointment({
    required this.id,
    required this.doctorName,
    this.patientName,
    required this.specialty,
    required this.date,
    required this.rawDate,
    required this.time,
    required this.type,
    required this.status,
    this.doctorId,
    this.googleMeetLink,
    this.notes,
    this.prescription,
    this.reason,
  });

  String get typeLabel {
    switch (type) {
      case AppointmentType.video:
        return 'Video Consultation';
      case AppointmentType.inPerson:
        return 'In-Person Visit';
    }
  }
  
  // Check if appointment is upcoming (scheduled or confirmed)
  bool get isUpcoming {
    return status == AppointmentStatus.scheduled || 
           status == AppointmentStatus.confirmed;
  }
  
  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Parse date and time
    final scheduledDate = json['scheduled_date'] ?? '';
    final scheduledTime = json['scheduled_time'] ?? '';
    
    // Format date (assuming YYYY-MM-DD format)
    String formattedDate = scheduledDate;
    if (scheduledDate.isNotEmpty) {
      try {
        final dateParts = scheduledDate.split('-');
        if (dateParts.length == 3) {
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final month = months[int.parse(dateParts[1]) - 1];
          formattedDate = '$month ${dateParts[2]}, ${dateParts[0]}';
        }
      } catch (e) {
        formattedDate = scheduledDate;
      }
    }
    
    // Format time (assuming HH:MM:SS format)
    String formattedTime = scheduledTime;
    if (scheduledTime.isNotEmpty) {
      try {
        final timeParts = scheduledTime.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = timeParts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          formattedTime = '$displayHour:$minute $period';
        }
      } catch (e) {
        formattedTime = scheduledTime;
      }
    }
    
    // Parse appointment type
    AppointmentType appointmentType = AppointmentType.video;
    final typeStr = json['appointment_type'] ?? 'video';
    if (typeStr == 'in_person') {
      appointmentType = AppointmentType.inPerson;
    }
    
    // Parse status
    AppointmentStatus appointmentStatus = AppointmentStatus.scheduled;
    final statusStr = json['status'] ?? 'scheduled';
    switch (statusStr) {
      case 'confirmed':
        appointmentStatus = AppointmentStatus.confirmed;
        break;
      case 'in_progress':
        appointmentStatus = AppointmentStatus.inProgress;
        break;
      case 'completed':
        appointmentStatus = AppointmentStatus.completed;
        break;
      case 'cancelled':
        appointmentStatus = AppointmentStatus.cancelled;
        break;
      default:
        appointmentStatus = AppointmentStatus.scheduled;
    }
    
    return Appointment(
      id: json['id'].toString(),
      doctorName: json['doctor_name'] ?? '',
      patientName: json['patient_name'],
      specialty: json['doctor_specialty'] ?? '',
      date: formattedDate,
      rawDate: scheduledDate, // Keep original format for filtering
      time: formattedTime,
      type: appointmentType,
      status: appointmentStatus,
      doctorId: json['doctor_id'] ?? json['doctor'],
      googleMeetLink: json['google_meet_link'],
      notes: json['notes'],
      prescription: json['prescription'],
      reason: json['reason'],
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_name': doctorName,
      'doctor_specialty': specialty,
      'scheduled_date': date,
      'scheduled_time': time,
      'appointment_type': type == AppointmentType.video ? 'video' : 'in_person',
      'status': status.toString().split('.').last,
    };
  }
}
