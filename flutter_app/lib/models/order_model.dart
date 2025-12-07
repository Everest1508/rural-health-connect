enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

class Order {
  final int id;
  final int patientId;
  final String patientName;
  final int pharmacistId;
  final String pharmacistName;
  final String pharmacistStore;
  final int? prescriptionId;
  final String? prescriptionTitle;
  final String? prescriptionImageUrl;
  final int? appointmentId;
  final String prescriptionText;
  final OrderStatus status;
  final String deliveryAddress;
  final double? patientLatitude;
  final double? patientLongitude;
  final String notes;
  final double? totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.pharmacistId,
    required this.pharmacistName,
    required this.pharmacistStore,
    this.prescriptionId,
    this.prescriptionTitle,
    this.prescriptionImageUrl,
    this.appointmentId,
    required this.prescriptionText,
    required this.status,
    required this.deliveryAddress,
    this.patientLatitude,
    this.patientLongitude,
    required this.notes,
    this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      patientId: json['patient'] ?? 0,
      patientName: json['patient_name'] ?? '',
      pharmacistId: json['pharmacist'] ?? 0,
      pharmacistName: json['pharmacist_name'] ?? '',
      pharmacistStore: json['pharmacist_store'] ?? '',
      prescriptionId: json['prescription'],
      prescriptionTitle: json['prescription_title'],
      prescriptionImageUrl: json['prescription_image'],
      appointmentId: json['appointment'],
      prescriptionText: json['prescription_text'] ?? '',
      status: _parseStatus(json['status']),
      deliveryAddress: json['delivery_address'] ?? '',
      patientLatitude: json['patient_latitude'] != null 
          ? double.tryParse(json['patient_latitude'].toString()) 
          : null,
      patientLongitude: json['patient_longitude'] != null 
          ? double.tryParse(json['patient_longitude'].toString()) 
          : null,
      notes: json['notes'] ?? '',
      totalAmount: json['total_amount'] != null 
          ? double.tryParse(json['total_amount'].toString()) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'patient_name': patientName,
      'pharmacist': pharmacistId,
      'pharmacist_name': pharmacistName,
      'pharmacist_store': pharmacistStore,
      'prescription': prescriptionId,
      'prescription_title': prescriptionTitle,
      'prescription_image': prescriptionImageUrl,
      'appointment': appointmentId,
      'prescription_text': prescriptionText,
      'status': status.name,
      'delivery_address': deliveryAddress,
      'patient_latitude': patientLatitude,
      'patient_longitude': patientLongitude,
      'notes': notes,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

