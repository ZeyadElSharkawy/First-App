# Firebase Integration Guide - Sign Up Page

## Overview

This guide explains the Firebase integration implemented in your signup page, including authentication, Firestore data storage, Cloud Storage file uploads, and searchable clinic management.

---

## Part 1: UI Components (SignUp.dart)

### 1. Profile Photo Picker (Top-Middle)

**Location:** Above the "Personal Info" section

```dart
GestureDetector(
  onTap: pickProfilePhoto,
  child: Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.grey[200],
      border: Border.all(color: Colors.teal, width: 3),
    ),
    child: pickedProfilePhoto != null
        ? ClipOval(child: Image.file(File(pickedProfilePhoto!.path)))
        : Icon(Icons.camera_alt) // Shows when no photo selected
  ),
)
```

**How it works:**

- Users tap the circular container to pick an image
- `image_picker` package handles image selection from gallery
- Selected image is stored in `XFile? pickedProfilePhoto` state variable
- Image preview is displayed after selection

---

### 2. Date of Birth Picker

**Location:** Personal Info section (after Confirm Password)

```dart
GestureDetector(
  onTap: selectDateOfBirth,
  child: Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(selectedDateOfBirth != null
            ? DateFormat('MMM dd, yyyy').format(selectedDateOfBirth!)
            : 'Select your date of birth'),
        Icon(Icons.calendar_today),
      ],
    ),
  ),
)
```

**How it works:**

- Tapping opens Flutter's `showDatePicker` dialog
- Users select a date between 1950 and today
- Selected date is stored in `DateTime? selectedDateOfBirth`
- `intl` package formats the date display

---

### 3. Searchable Clinic Dropdown

**Location:** Work Info section (Clinic Name field)

```dart
Stack(
  children: [
    TextField(
      controller: clinicNameCtrl,
      onChanged: (value) => loadAndSearchClinics(value),
      decoration: _buildInputDecoration('Search or enter clinic name'),
    ),
    if (showClinicDropdown && filteredClinics.isNotEmpty)
      Positioned(
        top: 50,
        child: Container(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final clinic = filteredClinics[index];
              return ListTile(
                title: Text(clinic['name']!),
                subtitle: Text(clinic['address']!),
                onTap: () => selectClinic(clinic),
              );
            },
          ),
        ),
      ),
  ],
)
```

**How it works:**

1. User types clinic name in the search field
2. `loadAndSearchClinics()` filters available clinics (from Firestore)
3. Matching clinics appear in a dropdown below the field
4. User can select a clinic, which auto-fills address & phone
5. Or user can enter a new clinic name (will be created in Firestore)

---

### 4. Audio/Video Recording Buttons

**Location:** Medical Info section (Record Audio/Video)

```dart
Row(
  children: [
    Expanded(
      child: GestureDetector(
        onTap: () {
          // TODO: Implement recording logic in backend
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(isRecordingAudio ? Icons.stop : Icons.mic),
              Text(isRecordingAudio ? 'Stop Audio' : 'Record Audio'),
            ],
          ),
        ),
      ),
    ),
    // Similar for Video button
  ],
)
```

**How it works:**

- Buttons show recording status (Record vs Stop)
- Button color changes when recording is active
- Placeholders for actual recording implementation
- Will store files in `File? recordedAudioFile` and `File? recordedVideoFile`

---

### 5. Medical Fields (Comma-Separated Input)

**Updated fields:**

- Diagnosis: "Enter diagnoses (comma-separated)"
- Previous Operations: "Enter operations (comma-separated)"
- Medications: "Enter medications (comma-separated)"

**Why comma-separated?**
These fields are stored as `List<String>` in Firestore, so users enter:

```
Example: "Hypertension, Diabetes, Asthma"
```

---

## Part 2: Backend Logic (lib/server/signup_backend.dart)

### 1. Upload File to Firebase Storage

```dart
Future<String?> uploadFileToFirebaseStorage(File file, String path) async {
  try {
    final storageRef = FirebaseStorage.instance.ref().child(path);
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}
```

**Path structure for files:**

- Profile photo: `profile_photos/{uid}/profile.jpg`
- Audio: `audio_files/{uid}/recording_{timestamp}.m4a`
- Video: `video_files/{uid}/recording_{timestamp}.mp4`

**Returns:** Download URL (String) or null if upload fails

---

### 2. Load Clinics from Firestore

```dart
Future<List<Map<String, String>>> loadAvailableClinics() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('clinics')
      .get();

  return snapshot.docs
      .map((doc) => {
        'id': doc.id,
        'name': doc['name'] ?? '',
        'address': doc['address'] ?? '',
        'phone': doc['phoneNumber'] ?? '',
      })
      .toList();
}
```

**What it does:**

- Fetches all clinic documents from Firestore
- Returns list of clinic info with ID, name, address, phone
- Called in `initState()` to populate dropdown options

---

### 3. Get or Create Clinic

```dart
Future<String> getOrCreateClinic({
  required String clinicName,
  required String clinicAddress,
  required String clinicPhone,
}) async {
  // Check if clinic exists by name
  final query = await FirebaseFirestore.instance
      .collection('clinics')
      .where('name', isEqualTo: clinicName.trim())
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    return query.docs.first.id; // Return existing clinic ID
  }

  // Create new clinic
  final newClinicRef = FirebaseFirestore.instance.collection('clinics').doc();
  await newClinicRef.set({
    'name': clinicName.trim(),
    'address': clinicAddress.trim(),
    'phoneNumber': clinicPhone.trim(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return newClinicRef.id; // Return new clinic ID
}
```

**Behavior:**

1. User enters clinic name
2. Backend searches Firestore for matching clinic
3. If found: Returns existing clinic ID
4. If not found: Creates new clinic document and returns its ID
5. Auto-filled address & phone helps validation

---

### 4. Save User Profile to Firestore

```dart
Future<void> saveUserProfileToFirestore({
  required String uid,
  required String fullName,
  required String email,
  // ... all other required fields
}) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'fullName': fullName,
    'email': email,
    'idNumber': idNumber,
    'gender': gender,
    'dateOfBirth': Timestamp.fromDate(dateOfBirth),

    'clinic': {
      'clinicId': clinicId,
      'name': clinicName,
      'address': clinicAddress,
      'phone': clinicPhone,
    },

    'specialization': {
      'main': mainSpeciality,
      'sub': subSpeciality,
      'degree': degree,
    },

    'medicalHistory': {
      'medications': medications, // List<String>
      'diagnosis': diagnosis,     // List<String>
      'operations': operations,   // List<String>
    },

    'files': {
      'profilePhotoUrl': profilePhotoUrl,
      'audioFileUrl': audioFileUrl,
      'videoFileUrl': videoFileUrl,
    },

    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

**Firestore Structure:**

```
users/
  {uid}/
    ├── fullName: "Dr. Ahmed Al-Mazrouei"
    ├── email: "doctor@example.com"
    ├── dateOfBirth: Timestamp(Jan 15, 1985)
    ├── gender: "Male"
    │
    ├── clinic/
    │   ├── clinicId: "clinic_doc_123"
    │   ├── name: "Al-Noor Medical Center"
    │   ├── address: "Dubai, UAE"
    │   └── phone: "+971-4-123-4567"
    │
    ├── specialization/
    │   ├── main: "Cardiology"
    │   ├── sub: "Interventional Cardiology"
    │   └── degree: "Specialist"
    │
    ├── medicalHistory/
    │   ├── medications: ["Aspirin", "Lisinopril", "Atorvastatin"]
    │   ├── diagnosis: ["Hypertension", "Hyperlipidemia"]
    │   └── operations: ["Bypass Surgery 2015"]
    │
    ├── files/
    │   ├── profilePhotoUrl: "https://..."
    │   ├── audioFileUrl: "https://..."
    │   └── videoFileUrl: "https://..."
    │
    ├── createdAt: Timestamp(Dec 21, 2025)
    └── updatedAt: Timestamp(Dec 21, 2025)
```

---

### 5. Complete Signup (Orchestration)

```dart
Future<void> completeSignup({
  // All required parameters...
  required Function(String) onSuccess,
  required Function(String) onError,
}) async {
  try {
    // Step 1: Create Firebase Auth user
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email, password);
    final uid = userCredential.user!.uid;

    // Step 2: Upload profile photo
    String? profilePhotoUrl = pickedProfilePhoto != null
        ? await uploadFileToFirebaseStorage(...)
        : null;

    // Step 3: Upload audio/video files
    String? audioUrl = recordedAudioFile != null
        ? await uploadFileToFirebaseStorage(...)
        : null;

    // Step 4: Get or create clinic
    String clinicId = await getOrCreateClinic(...);

    // Step 5: Save user to Firestore
    await saveUserProfileToFirestore(
      uid: uid,
      // ... all parameters
    );

    onSuccess('Signup completed successfully!');
  } catch (e) {
    onError(e.toString());
  }
}
```

**Complete Flow:**

```
User clicks Sign Up
    ↓
Validate all fields
    ↓
Call backend.completeSignup()
    ├─ Create Firebase Auth user (email + password)
    ├─ Upload profile photo to Cloud Storage
    ├─ Upload audio/video files to Cloud Storage
    ├─ Query/Create clinic in Firestore
    └─ Save user document to Firestore
    ↓
Success callback triggers
    ↓
Show 2FA enrollment dialog
```

---

## Part 3: Firebase Firestore Collections

### Clinics Collection

```
clinics/
  {autoId}/
    ├── name: String
    ├── address: String
    ├── phoneNumber: String
    ├── createdAt: Timestamp
    └── updatedAt: Timestamp
```

### Users Collection

See structure above in Part 2, Section 4.

---

## Part 4: Data Validation & Error Handling

### Password Validation Requirements

- Minimum 6 characters
- At least one capital letter (A-Z)
- At least one number (0-9)
- At least one special character (!@#$%^&\*)

### All Required Fields

- Full Name, ID Number, Date of Birth, Address
- City, Region, Mobile, Email, Password
- Clinic Name, Clinic Address, Clinic Phone
- Main Speciality, Degree

### Error Handling

```dart
on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    // Show: "Password is too weak..."
  } else if (e.code == 'email-already-in-use') {
    // Show: "An account already exists..."
  }
  // etc.
}
```

---

## Part 5: Next Steps - Recording Implementation

The audio/video recording buttons are UI placeholders. To implement actual recording:

1. **Install `record` package** (already added to pubspec.yaml)
2. **Implement recording methods in backend:**
   ```dart
   Future<void> startAudioRecording() async {
     final record = Record();
     await record.start();
     // Store file when stopped
   }
   ```
3. **Add platform permissions** (Android/iOS):
   - AndroidManifest.xml: RECORD_AUDIO permission
   - Info.plist: NSMicrophoneUsageDescription

---

## Summary

Your signup system now includes:

✅ Profile photo picker with preview
✅ Date of birth selection with calendar
✅ Searchable clinic dropdown with auto-fill
✅ Comma-separated medical field parsing
✅ Firebase authentication with strong password validation
✅ Cloud Storage file uploads (photos, audio, video)
✅ Firestore user profile storage with structured data
✅ Clinic lookup/creation logic
✅ 2FA enrollment after signup
✅ Comprehensive error handling

The backend (`signup_backend.dart`) is completely separate from UI, making it reusable and testable!
