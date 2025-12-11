class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String userType; // 'customer', 'driver', 'admin'
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.userType,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      userType: json['userType'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'userType': userType,
      'profileImage': profileImage,
    };
  }
}

class Driver extends User {
  final String vehicleNumber;
  final String licenseNumber;
  final double rating;
  final int totalPickups;
  final bool isAvailable;

  Driver({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.profileImage,
    required this.vehicleNumber,
    required this.licenseNumber,
    required this.rating,
    required this.totalPickups,
    required this.isAvailable,
  }) : super(userType: 'driver');

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profileImage'],
      vehicleNumber: json['vehicleNumber'],
      licenseNumber: json['licenseNumber'],
      rating: json['rating'].toDouble(),
      totalPickups: json['totalPickups'],
      isAvailable: json['isAvailable'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'vehicleNumber': vehicleNumber,
      'licenseNumber': licenseNumber,
      'rating': rating,
      'totalPickups': totalPickups,
      'isAvailable': isAvailable,
    });
    return json;
  }
}