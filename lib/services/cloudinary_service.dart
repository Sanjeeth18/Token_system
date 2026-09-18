import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/error/app_exception.dart';

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  /// Uploads an image file to Cloudinary and returns the secure URL.
  ///
  /// Supports:
  /// 1. Signed Uploads via API Key & API Secret (if configured).
  /// 2. Unsigned Uploads via Upload Preset (fallback).
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      const folder = 'mess_token_profiles';

      final bool useApiKeySecret = AppConstants.cloudinaryApiKey.trim().isNotEmpty &&
          AppConstants.cloudinaryApiSecret.trim().isNotEmpty;

      if (useApiKeySecret) {
        // Signed Upload with API Key and API Secret
        final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
        
        // String to sign must be parameter pairs sorted alphabetically followed by secret
        final stringToSign = 'folder=$folder&timestamp=$timestamp${AppConstants.cloudinaryApiSecret.trim()}';
        final signature = sha1.convert(utf8.encode(stringToSign)).toString();

        request.fields['api_key'] = AppConstants.cloudinaryApiKey.trim();
        request.fields['timestamp'] = timestamp;
        request.fields['signature'] = signature;
        request.fields['folder'] = folder;
      } else {
        // Unsigned Upload with Preset
        request.fields['upload_preset'] = AppConstants.cloudinaryUploadPreset;
        request.fields['folder'] = folder;
      }

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final secureUrl = data['secure_url'] as String?;
        if (secureUrl != null && secureUrl.isNotEmpty) {
          return secureUrl;
        }
        throw const FirestoreException('Invalid response format from Cloudinary');
      } else {
        throw FirestoreException(
          'Cloudinary upload failed (${response.statusCode}): $responseBody',
        );
      }
    } catch (e) {
      throw FirestoreException('Failed to upload image to Cloudinary: $e');
    }
  }
}
