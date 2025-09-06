// To parse this JSON data, do
//
//     final reportHistoryResponse = reportHistoryResponseFromJson(jsonString);

import 'dart:convert';

ReportHistoryResponse reportHistoryResponseFromJson(String str) =>
    ReportHistoryResponse.fromJson(json.decode(str));

String reportHistoryResponseToJson(ReportHistoryResponse data) =>
    json.encode(data.toJson());

class ReportHistoryResponse {
  String message;
  List<Datum> data;

  ReportHistoryResponse({required this.message, required this.data});

  factory ReportHistoryResponse.fromJson(Map<String, dynamic> json) =>
      ReportHistoryResponse(
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
  DateTime createdAt;
  DateTime updatedAt;
  String? imagePath;
  String lokasi;
  String? imageUrl;

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
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    judul: json["judul"],
    isi: json["isi"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    imagePath: json["image_path"],
    lokasi: json["lokasi"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "judul": judul,
    "isi": isi,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "image_path": imagePath,
    "lokasi": lokasi,
    "image_url": imageUrl,
  };
}
