
class UserModel {
  final String uId;
  final String username;
  final String email;

  UserModel({required this.uId, required this.username, required this.email,});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'uId': uId,
    };
  }
}
