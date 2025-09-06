// report_update_response.dart
class ReportUpdateResponse {
  final String message;
  final ReportUpdateData data;

  ReportUpdateResponse({required this.message, required this.data});

  factory ReportUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ReportUpdateResponse(
      message: json['message'] as String,
      data: ReportUpdateData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ReportUpdateData {
  final int id;
  final String userId;
  final String judul;
  final String isi;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? imagePath;
  final String? lokasi;
  final String? imageUrl;

  ReportUpdateData({
    required this.id,
    required this.userId,
    required this.judul,
    required this.isi,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.lokasi,
    this.imageUrl,
  });

  factory ReportUpdateData.fromJson(Map<String, dynamic> json) {
    return ReportUpdateData(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      imagePath: json['image_path'] as String?,
      lokasi: json['lokasi'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
