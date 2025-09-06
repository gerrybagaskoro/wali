// To parse this JSON data, do
//
//     final reportListResponse = reportListResponseFromJson(jsonString);

import 'dart:convert';

ReportListResponse reportListResponseFromJson(String str) =>
    ReportListResponse.fromJson(json.decode(str));

String reportListResponseToJson(ReportListResponse data) =>
    json.encode(data.toJson());

class ReportListResponse {
  String message;
  List<Datum> data;

  ReportListResponse({required this.message, required this.data});

  factory ReportListResponse.fromJson(Map<String, dynamic> json) =>
      ReportListResponse(
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String userId;
  String judul;
  String isi;
  String status;
  final String createdAt;
  DateTime updatedAt;
  String? imagePath;
  String? lokasi;
  String? imageUrl;
  User user;

  Datum({
    required this.id,
    required this.userId,
    required this.judul,
    required this.isi,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
    required this.lokasi,
    required this.imageUrl,
    required this.user,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    judul: json["judul"],
    isi: json["isi"],
    status: json["status"],
    createdAt: json["created_at"],
    updatedAt: DateTime.parse(json["updated_at"]),
    imagePath: json["image_path"],
    lokasi: json["lokasi"],
    imageUrl: json["image_url"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "judul": judul,
    "isi": isi,
    "status": status,
    "created_at": createdAt,
    "updated_at": updatedAt.toIso8601String(),
    "image_path": imagePath,
    "lokasi": lokasi,
    "image_url": imageUrl,
    "user": user.toJson(),
  };
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
