import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Replace these with your actual Supabase credentials
  static const String supabaseUrl =
      'https://qkxrrrsbooxzdjetcntl.supabase.co'; // e.g., 'https://xxxxx.supabase.co'
  static const String supabaseAnonKey =
      'sb_publishable_mTA4XdWrOzBdIR9kq-KVNA_drraNoJX'; // Your anon/public key
  static const String bucketName = 'clinic-app';

  static SupabaseClient? _client;

  /// Initialize Supabase (call this once in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Upload a file to Supabase Storage
  /// Returns the public URL of the uploaded file
  static Future<String> uploadFile({
    required File file,
    required String folder, // e.g., 'profile', 'medical', 'audio'
    required String fileName,
    required String uid, // Firebase UID for authenticated uploads
  }) async {
    try {
      // Construct path: users/{firebaseUid}/{folder}/{fileName}
      final filePath = 'public/$uid/$folder/$fileName';

      // Upload file to Supabase
      // Modify this in supabase_service.dart
      await client.storage.from(bucketName).upload(
        filePath,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: false,
          // Add this line to force the correct type for audio
          contentType: folder == 'audio' ? 'audio/m4a' : 'image/jpeg',
        ),
      );

      // Get public URL
      final publicUrl = client.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload profile photo
  static Future<String> uploadProfilePhoto(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await uploadFile(
      file: file,
      folder: 'profile',
      fileName: 'avatar_$timestamp.jpg',
      uid: uid,
    );
  }

  /// Upload medical certificate
  static Future<String> uploadMedicalCertificate(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await uploadFile(
      file: file,
      folder: 'medical',
      fileName: 'certificate_$timestamp.jpg',
      uid: uid,
    );
  }

  /// Upload medical license
  static Future<String> uploadMedicalLicense(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await uploadFile(
      file: file,
      folder: 'medical',
      fileName: 'license_$timestamp.jpg',
      uid: uid,
    );
  }

  /// Upload audio file
  static Future<String> uploadAudioFile(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    return await uploadFile(
      file: file,
      folder: 'audio',
      fileName: 'note_$timestamp.$extension',
      uid: uid,
    );
  }

  /// Upload video file
  static Future<String> uploadVideoFile(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    return await uploadFile(
      file: file,
      folder: 'video',
      fileName: 'video_$timestamp.$extension',
      uid: uid,
    );
  }

  /// Delete a file from Supabase Storage
  static Future<void> deleteFile(String fileUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // Find the index of 'public' in the path
      final publicIndex = pathSegments.indexOf('public');
      if (publicIndex == -1) {
        throw Exception('Invalid file URL');
      }

      // Get the file path after 'public/bucket-name/'
      final filePath = pathSegments.sublist(publicIndex + 2).join('/');

      // Delete file from Supabase
      await client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
