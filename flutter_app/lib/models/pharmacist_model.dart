class Pharmacist {
  final int id;
  final String name;
  final String email;
  final String storeName;
  final String storeAddress;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final bool isActive;
  final double? distanceKm;

  Pharmacist({
    required this.id,
    required this.name,
    required this.email,
    required this.storeName,
    required this.storeAddress,
    this.latitude,
    this.longitude,
    this.phone,
    required this.isActive,
    this.distanceKm,
  });

  factory Pharmacist.fromJson(Map<String, dynamic> json) {
    return Pharmacist(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      storeName: json['store_name'] ?? '',
      storeAddress: json['store_address'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
      distanceKm: json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'store_name': storeName,
      'store_address': storeAddress,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'is_active': isActive,
      'distance_km': distanceKm,
    };
  }
}

