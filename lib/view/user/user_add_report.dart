// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io' show File; // masih boleh untuk mobile preview

import 'package:flutter/foundation.dart'; // cek kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wali_app/api/endpoint.dart';
import 'package:wali_app/extension/navigation.dart';
import 'package:wali_app/preference/shared_preference.dart';
import 'package:wali_app/utils/dialog_utils.dart';
import 'package:wali_app/utils/snackbar_utils.dart';

class UserAddReport extends StatefulWidget {
  const UserAddReport({super.key});

  @override
  State<UserAddReport> createState() => _UserAddReportState();
}

class _UserAddReportState extends State<UserAddReport> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  XFile? _selectedImage; // ✅ ganti File → XFile
  Uint8List? _webImageBytes; // khusus untuk Web preview
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _selectedImage = pickedImage;
          _webImageBytes = bytes;
        });
      } else {
        setState(() => _selectedImage = pickedImage);
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final token = await PreferenceHandler.getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      String? imageBase64;
      if (_selectedImage != null) {
        final bytes = kIsWeb
            ? _webImageBytes!
            : await File(
                _selectedImage!.path,
              ).readAsBytes(); // ✅ handle mobile & web
        imageBase64 = base64Encode(bytes);
      }

      final response = await http.post(
        Uri.parse(Endpoint.laporan),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'judul': _titleController.text,
          'isi': _descriptionController.text,
          'lokasi': _locationController.text,
          if (imageBase64 != null)
            'image_base64': 'data:image/jpeg;base64,$imageBase64',
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Laporan berhasil dikirim!');
          context.pop(true); // return true biar dashboard bisa refresh
        }
      } else {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Gagal mengirim laporan: ${response.body}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmAndSubmit() async {
    final confirm = await DialogUtils.showConfirmationDialog(
      context,
      title: "Konfirmasi",
      message: "Apakah kamu yakin ingin mengirim laporan ini?",
      confirmText: "Kirim",
      cancelText: "Batal",
    );

    if (confirm) {
      _submitReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan Baru')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Laporan',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Judul harus diisi'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Lokasi harus diisi'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Deskripsi harus diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ✅ Preview gambar mobile vs web
                  if (_selectedImage != null)
                    kIsWeb
                        ? Image.memory(
                            _webImageBytes!,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            height: 200,
                            fit: BoxFit.cover,
                          ),

                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: _pickImage,
                    child: const Text('Pilih Foto'),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _confirmAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Kirim Laporan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Laporan sedang dikirim...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
