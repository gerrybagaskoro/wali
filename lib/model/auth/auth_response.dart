// To parse this JSON data, do
//
//     final userAuthResponse = userAuthResponseFromJson(jsonString);

import 'dart:convert';

import 'package:wali_app/preference/shared_preference.dart';

UserAuthResponse userAuthResponseFromJson(String str) =>
    UserAuthResponse.fromJson(json.decode(str));

String userAuthResponseToJson(UserAuthResponse data) =>
    json.encode(data.toJson());

class UserAuthResponse {
  String message;
  Data data;

  UserAuthResponse({required this.message, required this.data});

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) =>
      UserAuthResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  String token;
  User user;

  Data({required this.token, required this.user});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(token: json["token"], user: User.fromJson(json["user"]));

  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}

class User {
  int id;
  String name;
  String email;
  dynamic emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

// EXTENSIONS - PASTIKAN ADA DI BAWAH
extension AuthResponseExtensions on UserAuthResponse {
  Future<void> saveToPreferences() async {
    await PreferenceHandler.saveToken(data.token);
    await PreferenceHandler.saveLogin(true);
    await PreferenceHandler.saveUserData(json.encode(data.user.toJson()));
  }
}

extension AuthResponseStaticExtensions on UserAuthResponse {
  static Future<bool> isLoggedIn() async {
    final token = await PreferenceHandler.getToken();
    return token != null;
  }

  static Future<User?> getSavedUser() async {
    final userData = await PreferenceHandler.getUserData();
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  static Future<void> logout() async {
    await PreferenceHandler.clearAll();
  }
}
