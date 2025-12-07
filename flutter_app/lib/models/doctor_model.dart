class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String experience;
  final bool available;
  final int fee;
  final String? clinicAddress;
  final double? latitude;
  final double? longitude;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.available,
    required this.fee,
    this.clinicAddress,
    this.latitude,
    this.longitude,
  });

  // Get initials from doctor name
  String get initials {
    if (name.isEmpty) return 'DR';
    final parts = name.split(' ').where((n) => n.isNotEmpty).toList();
    if (parts.length >= 2) {
      return parts.skip(1).where((n) => n.isNotEmpty).map((n) => n[0]).join('').toUpperCase();
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }
  
  // Create from JSON
  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Handle fee - can be string or number
    int fee = 0;
    if (json['fee'] != null) {
      if (json['fee'] is String) {
        fee = (double.tryParse(json['fee']) ?? 0).toInt();
      } else if (json['fee'] is num) {
        fee = json['fee'].toInt();
      }
    }
    
    // Handle rating - can be string or number
    double rating = 0.0;
    if (json['rating'] != null) {
      if (json['rating'] is String) {
        rating = double.tryParse(json['rating']) ?? 0.0;
      } else if (json['rating'] is num) {
        rating = json['rating'].toDouble();
      }
    }
    
    // Handle experience - can be int or string
    String experience = '0 years';
    if (json['experience'] != null) {
      if (json['experience'] is int) {
        experience = '${json['experience']} years';
      } else if (json['experience'] is String) {
        experience = json['experience'];
      }
    }
    
    return Doctor(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: rating,
      experience: experience,
      available: json['available'] ?? false,
      fee: fee,
      clinicAddress: json['clinic_address'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'experience': experience,
      'available': available,
      'fee': fee,
      'clinic_address': clinicAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
