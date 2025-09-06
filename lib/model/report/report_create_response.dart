// To parse this JSON data, do
//
//     final createLaporanResponse = createLaporanResponseFromJson(jsonString);

import 'dart:convert';

CreateLaporanResponse createLaporanResponseFromJson(String str) =>
    CreateLaporanResponse.fromJson(json.decode(str));

String createLaporanResponseToJson(CreateLaporanResponse data) =>
    json.encode(data.toJson());

class CreateLaporanResponse {
  String message;
  Data data;

  CreateLaporanResponse({required this.message, required this.data});

  factory CreateLaporanResponse.fromJson(Map<String, dynamic> json) =>
      CreateLaporanResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int id;
  String judul;
  String isi;
  String lokasi;
  dynamic status;
  String imageUrl;
  String imagePath;

  Data({
    required this.id,
    required this.judul,
    required this.isi,
    required this.lokasi,
    required this.status,
    required this.imageUrl,
    required this.imagePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    judul: json["judul"],
    isi: json["isi"],
    lokasi: json["lokasi"],
    status: json["status"],
    imageUrl: json["image_url"],
    imagePath: json["image_path"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "judul": judul,
    "isi": isi,
    "lokasi": lokasi,
    "status": status,
    "image_url": imageUrl,
    "image_path": imagePath,
  };
}
