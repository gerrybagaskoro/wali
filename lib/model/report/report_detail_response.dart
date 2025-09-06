// To parse this JSON data, do
//
//     final reportDetailResponse = reportDetailResponseFromJson(jsonString);

import 'dart:convert';

ReportDetailResponse reportDetailResponseFromJson(String str) =>
    ReportDetailResponse.fromJson(json.decode(str));

String reportDetailResponseToJson(ReportDetailResponse data) =>
    json.encode(data.toJson());

class ReportDetailResponse {
  String message;
  Data data;

  ReportDetailResponse({required this.message, required this.data});

  factory ReportDetailResponse.fromJson(Map<String, dynamic> json) =>
      ReportDetailResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  String userId;
  String judul;
  String isi;
  String status;
  String createdAt; // ✅ UBAH KE String
  String updatedAt; // ✅ UBAH KE String
  String imagePath;
  String lokasi;
  String imageUrl;

  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["user_id"],
    judul: json["judul"],
    isi: json["isi"],
    status: json["status"],
    createdAt: json["created_at"], // ✅ TETAP STRING
    updatedAt: json["updated_at"], // ✅ TETAP STRING
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
    "created_at": createdAt,
    "updated_at": updatedAt,
    "image_path": imagePath,
    "lokasi": lokasi,
    "image_url": imageUrl,
  };
}
