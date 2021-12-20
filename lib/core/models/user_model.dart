class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String userType;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.userType,
    required this.lastLogin,
  });

  Map<String, dynamic> get toMap => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'userType': userType,
        'lastLogin': lastLogin.toIso8601String()
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      userType: map['userType'],
      lastLogin: DateTime.parse(map['lastLogin']));
}
