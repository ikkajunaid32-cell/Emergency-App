class AppUser {
  late String name;
  late String email;
  late String phone;
  late String userType;
  late String id;
  String? imageUrl;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? latitude;
  String? longitude;

  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.id,
    this.imageUrl,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  AppUser.fromMap(Map<String, dynamic> data) {
    id = data["id"]?.toString() ?? '';
    email = data["email"]?.toString() ?? '';
    name = data["userName"]?.toString() ?? data["UserName"]?.toString() ?? '';
    phone = data["phone"]?.toString() ?? data["Phone"]?.toString() ?? '';
    userType = data["userType"]?.toString() ?? data["UserType"]?.toString() ?? 'User';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'userName': name,
      'phone': phone,
      'userType': userType,
    };
  }
}
