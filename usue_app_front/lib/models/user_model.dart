class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role; // admin | user
  final String phone;
  final String address;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone = '',
    this.address = '',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        username: json['username'] ?? json['email'] ?? '',
        email: json['email'] ?? '',
        fullName: json['fullName'] ?? json['full_name'] ?? json['username'] ?? '',
        role: json['role'] ?? 'user',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'fullName': fullName,
        'role': role,
        'phone': phone,
        'address': address,
      };
}
