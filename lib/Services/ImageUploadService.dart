import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../Services/SupaBaseService.dart';

class ImageUploadService extends GetxService {
  late final SupabaseClient _client;
  final _uuid = Uuid();

  Future<ImageUploadService> init() async {
    _client = Get
        .find<SupabaseService>()
        .client;
    return this;
  }

  /// Upload property image to Supabase Storage
  Future<String> uploadPropertyImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExt';
      final filePath = 'properties/$fileName';

      await _client.storage.from('property-images').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          contentType: _getContentType(fileExt),
          upsert: false,
        ),
      );

      // Get the public URL
      final publicUrl = _client.storage
          .from('property-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile image to Supabase Storage
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = path.extension(imageFile.path);
      final fileName = '$userId$fileExt';
      final filePath = 'profiles/$fileName';

      // Delete existing profile image if it exists
      try {
        await _client.storage.from('profile-images').remove([filePath]);
      } catch (e) {
        // Ignore if file doesn't exist
      }

      await _client.storage.from('profile-images').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          contentType: _getContentType(fileExt),
          upsert: true,
        ),
      );

      // Get the public URL
      final publicUrl = _client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload multiple property images
  Future<List<String>> uploadPropertyImages(List<File> imageFiles) async {
    List<String> urls = [];

    for (File file in imageFiles) {
      try {
        final url = await uploadPropertyImage(file);
        urls.add(url);
      } catch (e) {
        // Continue with other images even if one fails
        print('Failed to upload image: $e');
      }
    }

    if (urls.isEmpty && imageFiles.isNotEmpty) {
      throw Exception('Failed to upload any images');
    }

    return urls;
  }

  /// Delete property image from storage
  Future<void> deletePropertyImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.length - 2).join('/');

      await _client.storage.from('property-images').remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete multiple property images
  Future<void> deletePropertyImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      try {
        await deletePropertyImage(url);
      } catch (e) {
        print('Failed to delete image: $e');
      }
    }
  }

  /// Get content type based on file extension
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Validate image file
  bool isValidImageFile(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final fileExt = path.extension(file.path).toLowerCase();
    return validExtensions.contains(fileExt);
  }

  /// Check file size (max 5MB)
  bool isValidFileSize(File file) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    return file.lengthSync() <= maxSizeInBytes;
  }

  /// Validate image before upload
  String? validateImage(File file) {
    if (!isValidImageFile(file)) {
      return 'Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.';
    }

    if (!isValidFileSize(file)) {
      return 'File size too large. Maximum size is 5MB.';
    }

    return null; // Valid
  }
}