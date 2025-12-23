import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'supabase_service.dart';

/// Load Available Clinics from Firestore
/// Returns a list of clinic documents with id, name, address, and phone
Future<List<Map<String, String>>> loadAvailableClinics() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('clinics')
        .get();

    return snapshot.docs
        .map(
          (doc) => <String, String>{
            'id': doc.id,
            'name': (doc['name'] ?? '') as String,
            'address': (doc['address'] ?? '') as String,
            'phone': (doc['phoneNumber'] ?? '') as String,
          },
        )
        .toList();
  } catch (e) {
    print('Error loading clinics: $e');
    return [];
  }
}

/// Get or Create Clinic
/// Checks if clinic exists, if not creates a new one
/// Returns the clinic document ID
Future<String> getOrCreateClinic({
  required String clinicName,
  required String clinicAddress,
  required String clinicPhone,
}) async {
  try {
    // Query for existing clinic by name and address
    final query = await FirebaseFirestore.instance
        .collection('clinics')
        .where('name', isEqualTo: clinicName.trim())
        .limit(1)
        .get();

    // If clinic exists, return its ID
    if (query.docs.isNotEmpty) {
      print('Existing clinic found with ID: ${query.docs.first.id}');
      return query.docs.first.id;
    }

    // Create new clinic document
    final newClinicRef = FirebaseFirestore.instance.collection('clinics').doc();
    await newClinicRef.set({
      'name': clinicName.trim(),
      'address': clinicAddress.trim(),
      'phoneNumber': clinicPhone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('New clinic created with ID: ${newClinicRef.id}');
    return newClinicRef.id;
  } catch (e) {
    print('Error managing clinic: $e');
    rethrow;
  }
}

/// Save User Profile to Firestore with Multiple Clinics
/// Creates a complete user document with all signup information
Future<void> saveUserProfileToFirestore({
  required String uid,
  required String fullName,
  required String email,
  required String idNumber,
  required String idType,
  required String gender,
  required DateTime? dateOfBirth,
  required String address,
  required String city,
  required String region,
  required String mobileNumber,
  required String countryCode,
  required List<Map<String, String>> clinics, // Updated: List of clinics
  required String mainSpeciality,
  required String subSpeciality,
  required String degree,
  required List<String> medications,
  required List<String> diagnosis,
  required List<String> operations,
  required String? profilePhotoUrl,
  required String? certificateUrl,
  required String? licenseUrl,
  required String? audioFileUrl,
  required String? videoFileUrl,
}) async {
  try {
    // Process all clinics and get their IDs
    List<String> clinicIds = [];
    List<Map<String, String>> clinicsData = [];
    
    for (var clinic in clinics) {
      String id = await getOrCreateClinic(
        clinicName: clinic['name']!,
        clinicAddress: clinic['address']!,
        clinicPhone: clinic['phone']!,
      );
      clinicIds.add(id);
      clinicsData.add({
        'clinicId': id,
        'name': clinic['name']!,
        'address': clinic['address']!,
        'phone': clinic['phone']!,
      });
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'idNumber': idNumber,
      'idType': idType,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth)
          : null,
      'address': address,
      'city': city,
      'region': region,
      'mobileNumber': mobileNumber,
      'countryCode': countryCode,
      'clinicIds': clinicIds, // Store list of clinic IDs
      'clinicsData': clinicsData, // Store clinic details
      'specialization': {
        'main': mainSpeciality,
        'sub': subSpeciality,
        'degree': degree,
      },
      'medicalHistory': {
        'medications': medications,
        'diagnosis': diagnosis,
        'operations': operations,
      },
      'files': {
        'profilePhotoUrl': profilePhotoUrl, // Supabase URL
        'certificateUrl': certificateUrl, // Supabase URL
        'licenseUrl': licenseUrl, // Supabase URL
        'audioFileUrl': audioFileUrl, // Supabase URL
        'videoFileUrl': videoFileUrl, // Supabase URL
      },
      'accountStatus': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('User profile saved successfully for UID: $uid');
    print('Saved ${clinics.length} clinics');
  } catch (e) {
    print('Error saving user profile to Firestore: $e');
    rethrow;
  }
}

/// Complete Signup Process
/// Orchestrates the entire signup flow:
/// 1. Create Firebase Auth user
/// 2. Upload files to Supabase
/// 3. Get or create clinics
/// 4. Save user document to Firestore with Supabase URLs
Future<void> completeSignup({
  required String email,
  required String password,
  required String fullName,
  required String idNumber,
  required String idType,
  required String gender,
  required DateTime? dateOfBirth,
  required String address,
  required String city,
  required String region,
  required String mobileNumber,
  required String countryCode,
  required List<Map<String, String>> clinics, // Updated: List of clinics
  required String mainSpeciality,
  required String subSpeciality,
  required String degree,
  required List<String> medications,
  required List<String> diagnosis,
  required List<String> operations,
  required File? profilePhotoFile,
  required File? certificateFile,
  required File? licenseFile,
  required File? audioFile,
  required Function(String) onSuccess,
  required Function(String) onError,
}) async {
  try {
    // Step 1: Create Firebase Auth user
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

    final String uid = userCredential.user!.uid;
    print('User authenticated with UID: $uid');
    print('Processing ${clinics.length} clinics');

    // Step 2: Upload files to Supabase and get URLs
    String? profilePhotoUrl;
    String? certificateUrl;
    String? licenseUrl;
    String? audioFileUrl;
    String? videoFileUrl;

    // Upload profile photo to Supabase
    if (profilePhotoFile != null) {
      try {
        profilePhotoUrl = await SupabaseService.uploadProfilePhoto(
          profilePhotoFile,
          uid,
        );
        print('Profile photo uploaded: $profilePhotoUrl');
      } catch (e) {
        print('Error uploading profile photo: $e');
        // Continue even if profile photo upload fails
      }
    }

    // Upload certificate to Supabase
    if (certificateFile != null) {
      try {
        certificateUrl = await SupabaseService.uploadMedicalCertificate(
          certificateFile,
          uid,
        );
        print('Certificate uploaded: $certificateUrl');
      } catch (e) {
        print('Error uploading certificate: $e');
      }
    }

    // Upload license to Supabase
    if (licenseFile != null) {
      try {
        licenseUrl = await SupabaseService.uploadMedicalLicense(
          licenseFile,
          uid,
        );
        print('License uploaded: $licenseUrl');
      } catch (e) {
        print('Error uploading license: $e');
      }
    }

    // Upload audio file to Supabase
    if (audioFile != null) {
      try {
        audioFileUrl = await SupabaseService.uploadAudioFile(audioFile, uid);
        print('Audio file uploaded: $audioFileUrl');
      } catch (e) {
        print('Error uploading audio: $e');
      }
    }

    // Step 4: Save user profile to Firestore with Supabase URLs and multiple clinics
    await saveUserProfileToFirestore(
      uid: uid,
      fullName: fullName,
      email: email,
      idNumber: idNumber,
      idType: idType,
      gender: gender,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      region: region,
      mobileNumber: mobileNumber,
      countryCode: countryCode,
      clinics: clinics, // Now passing list of clinics
      mainSpeciality: mainSpeciality,
      subSpeciality: subSpeciality,
      degree: degree,
      medications: medications,
      diagnosis: diagnosis,
      operations: operations,
      profilePhotoUrl: profilePhotoUrl, // Supabase URL
      certificateUrl: certificateUrl, // Supabase URL
      licenseUrl: licenseUrl, // Supabase URL
      audioFileUrl: audioFileUrl, // Supabase URL
      videoFileUrl: videoFileUrl, // Supabase URL
    );

    onSuccess(
      'Signup completed successfully!',
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'Authentication error';

    if (e.code == 'weak-password') {
      errorMessage =
          'Password is too weak. Use at least 6 characters with uppercase, numbers, and special characters.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'An account already exists with this email.';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'Invalid email address.';
    } else {
      errorMessage = e.message ?? 'Authentication failed.';
    }

    onError(errorMessage);
  } catch (e) {
    onError('Signup failed: $e');
  }
}

/// Convert comma-separated string to List<String>
/// Splits by comma and trims whitespace from each item
List<String> parseCommaSeparatedString(String input) {
  if (input.isEmpty) return [];

  return input
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}