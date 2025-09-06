import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/model/report/report_detail_response.dart';

Future<ReportDetailResponse> updateLaporan(
  int laporanId,
  String token,
  String judul,
  String isi,
  String lokasi,
) async {
  final response = await http.put(
    Uri.parse('${Endpoint.laporan}/$laporanId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({'judul': judul, 'isi': isi, 'lokasi': lokasi}),
  );

  if (response.statusCode == 200) {
    return ReportDetailResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update laporan: ${response.body}');
  }
}
