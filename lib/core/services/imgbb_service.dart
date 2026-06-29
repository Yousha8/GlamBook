import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ImgBBService {
  final Dio _dio = Dio();

  Future<String?> uploadImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'key': AppConstants.imgbbApiKey,
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        AppConstants.imgbbUploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          // You can implement progress tracking if needed
          print('Upload Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['url'] as String;
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      print('ImgBB Upload Error: $e');
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> files) async {
    List<String> urls = [];
    for (var file in files) {
      final url = await uploadImage(file);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}
