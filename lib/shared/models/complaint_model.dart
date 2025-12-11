class Complaint {
  final String id;
  final String userId;
  final String category;
  final String description;
  final List<String> images;
  final String location;
  final String status;
  final DateTime createdAt;
  final String? driverId;
  final String? driverName;

  Complaint({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.images,
    required this.location,
    required this.status,
    required this.createdAt,
    this.driverId,
    this.driverName,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      userId: json['userId'],
      category: json['category'],
      description: json['description'],
      images: List<String>.from(json['images']),
      location: json['location'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      driverId: json['driverId'],
      driverName: json['driverName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'description': description,
      'images': images,
      'location': location,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'driverId': driverId,
      'driverName': driverName,
    };
  }
}