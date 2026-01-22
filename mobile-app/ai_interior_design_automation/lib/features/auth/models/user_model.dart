class User {
  final String id;
  final String fullName;
  final String email;
  final String? mobile;
  final String? profilePicture;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.mobile,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'],
      profilePicture: json['profile_picture'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'profile_picture': profilePicture,
    };
  }
}
