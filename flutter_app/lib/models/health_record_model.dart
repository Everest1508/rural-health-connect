class HealthRecord {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String date;
  final String title;
  final String description;
  final String? createdById;
  final String? createdByName;
  final String? attachmentUrl;
  final String createdAt;
  final String updatedAt;

  HealthRecord({
    required this.id,
    required this.patientId,
    this.appointmentId,
    required this.date,
    required this.title,
    required this.description,
    this.createdById,
    this.createdByName,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'].toString(),
      patientId: json['patient'].toString(),
      appointmentId: json['appointment_id']?.toString(),
      date: json['date'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdById: json['created_by']?.toString(),
      createdByName: json['created_by_name'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'appointment': appointmentId,
      'date': date,
      'title': title,
      'description': description,
      'created_by': createdById,
      'created_by_name': createdByName,
      'attachment_url': attachmentUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

