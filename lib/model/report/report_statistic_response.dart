// To parse this JSON data, do
//
//     final reportStatisticResponse = reportStatisticResponseFromJson(jsonString);

import 'dart:convert';

ReportStatisticResponse reportStatisticResponseFromJson(String str) =>
    ReportStatisticResponse.fromJson(json.decode(str));

String reportStatisticResponseToJson(ReportStatisticResponse data) =>
    json.encode(data.toJson());

class ReportStatisticResponse {
  String message;
  Data data;

  ReportStatisticResponse({required this.message, required this.data});

  factory ReportStatisticResponse.fromJson(Map<String, dynamic> json) =>
      ReportStatisticResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class Data {
  int masuk;
  int proses;
  int selesai;

  Data({required this.masuk, required this.proses, required this.selesai});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    masuk: json["masuk"],
    proses: json["proses"],
    selesai: json["selesai"],
  );

  Map<String, dynamic> toJson() => {
    "masuk": masuk,
    "proses": proses,
    "selesai": selesai,
  };
}
