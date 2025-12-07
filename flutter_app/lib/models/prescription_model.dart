class Prescription {
  final int id;
  final String title;
  final String? imageUrl;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image'],
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imageUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

