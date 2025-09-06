// report_detail_response.dart
class ReportDetailResponse {
  final String message;
  final ReportDetailData data;

  ReportDetailResponse({required this.message, required this.data});

  factory ReportDetailResponse.fromJson(Map<String, dynamic> json) {
    return ReportDetailResponse(
      message: json['message'] as String,
      data: ReportDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data.toJson()};
  }
}

class ReportDetailData {
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
  final ReportUser? user;

  ReportDetailData({
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
    this.user,
  });

  factory ReportDetailData.fromJson(Map<String, dynamic> json) {
    return ReportDetailData(
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
      user: json['user'] != null
          ? ReportUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'isi': isi,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path': imagePath,
      'lokasi': lokasi,
      'image_url': imageUrl,
      'user': user?.toJson(),
    };
  }
}

class ReportUser {
  final int id;
  final String name;
  final String email;
  final dynamic emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  ReportUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
