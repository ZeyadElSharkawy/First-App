import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'Classes/NestedSections.dart';
import 'Classes/Buttons.dart';
import 'Classes/Labels.dart';
import 'Classes/Dropdown.dart';
import 'Classes/Language.dart';
import 'server/signup_backend.dart' as backend;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late PageController _pageController;
  int currentPage = 0;
  bool isArabic = false;

  bool isLoadingAuth = false;

  // Profile Photo & File Variables
  XFile? pickedProfilePhoto;
  XFile? certificateFile;
  XFile? licenseFile;
  final ImagePicker imagePicker = ImagePicker();

  // Date of Birth Variable
  DateTime? selectedDateOfBirth;

  // Recording Variables
  bool isRecordingAudio = false;
  bool isRecordingVideo = false;
  File? recordedAudioFile;
  File? recordedVideoFile;
  Duration _recordingDuration = Duration.zero; // FIX: Added missing variable

  // Add timer for recording duration
  Timer? _recordingTimer;

  // Uncomment if you have the audio_recorder package
  // late final RecorderController recorderController;
  // late final Directory appDocDirectory;

  // Clinic Search Variables
  List<Map<String, String>> availableClinics = [];
  List<Map<String, String>> filteredClinics = [];
  bool showClinicDropdown = false;

  // Personal Info Controllers
  final fullNameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // Work Info Controllers
  final clinicNameCtrl = TextEditingController();
  final clinicAddressCtrl = TextEditingController();
  final clinicPhoneCtrl = TextEditingController();

  // Medical Info Controllers
  final diagnosisCtrl = TextEditingController();
  final operationsCtrl = TextEditingController();
  final medicationsCtrl = TextEditingController();

  // Dropdown values
  String? selectedIdType = 'National ID';
  String? selectedGender = 'Male';
  String? selectedCity;
  String? selectedRegion;
  String? selectedCountryCode = '🇸🇦 +966';
  String? selectedMainSpeciality = 'Cardiology';
  String? selectedSubSpeciality = 'Sub Specialty 1';
  String? selectedDegree = 'MD';
  String? selectedClinicCountryCode = '🇸🇦 +966';

  // Error state variables for real-time validation
  String? fullNameError;
  String? idError;
  String? addressError;
  String? mobileError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? dateOfBirthError;
  String? clinicNameError;
  String? clinicAddressError;
  String? clinicPhoneError;
  String? diagnosisError;
  String? operationsError;
  String? medicationsError;
  String? certificateError;
  String? licenseError;
  String? profilePhotoError;

  // Sample data
  final idTypes = ['National ID', 'Passport'];
  final cities = ['Riyadh', 'Jeddah', 'Dammam', 'Medina'];
  final regions = ['Region 1', 'Region 2', 'Region 3'];
  final countryCodes = [
    '🇸🇦 +966', // Saudi Arabia
    '🇺🇸 +1', // United States
    '🇬🇧 +44', // United Kingdom
    '🇮🇳 +91', // India
    '🇦🇪 +971', // UAE
    '🇪🇬 +20', // Egypt
    '🇯🇴 +962', // Jordan
    '🇱🇧 +961', // Lebanon
    '🇰🇼 +965', // Kuwait
    '🇧🇭 +973', // Bahrain
    '🇶🇦 +974', // Qatar
    '🇴🇲 +968', // Oman
    '🇾🇪 +967', // Yemen
    '🇵🇰 +92', // Pakistan
    '🇧🇩 +880', // Bangladesh
    '🇨🇦 +1', // Canada
    '🇦🇺 +61', // Australia
    '🇯🇵 +81', // Japan
    '🇩🇪 +49', // Germany
    '🇫🇷 +33', // France
  ];
  final mainSpecialties = [
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
  ];
  final subSpecialties = ['Sub Specialty 1', 'Sub Specialty 2'];
  final degrees = ['MD', 'BDS', 'Specialist', 'Consultant'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // _initializeRecorder();
    _loadClinicsFromBackend();
  }

  // Initialize audio recorder
  // Uncomment if you have the audio recording package
  // Future<void> _initializeRecorder() async {
  //   try {
  //     appDocDirectory = await getApplicationDocumentsDirectory();
  //     recorderController = RecorderController();
  //     await recorderController.checkPermission();
  //   } catch (e) {
  //     _showError('Error initializing recorder: $e');
  //   }
  // }

  // Load clinics from Firestore on startup
  Future<void> _loadClinicsFromBackend() async {
    try {
      final clinics = await backend.loadAvailableClinics();
      setState(() {
        availableClinics = clinics;
        filteredClinics = clinics;
      });
    } catch (e) {
      _showError('Error loading clinics: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // recorderController.dispose();

    // Stop recording timer if active
    _recordingTimer?.cancel();

    fullNameCtrl.dispose();
    idCtrl.dispose();
    addressCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    clinicNameCtrl.dispose();
    clinicAddressCtrl.dispose();
    clinicPhoneCtrl.dispose();
    diagnosisCtrl.dispose();
    operationsCtrl.dispose();
    medicationsCtrl.dispose();
    super.dispose();
  }

  // FIX: Added missing method to toggle audio recording
  void _toggleAudioRecording() {
    setState(() {
      if (isRecordingAudio) {
        // Stop recording
        isRecordingAudio = false;
        _recordingTimer?.cancel();
        _recordingDuration = Duration.zero;

        // TODO: Implement actual audio recording stop logic
        // This is a placeholder - you'll need to implement actual audio recording
        _showInfo('Audio recording stopped (placeholder)');

        // Placeholder file for demonstration
        // In a real app, this would be the actual recorded audio file
        recordedAudioFile = File('path/to/recorded_audio.wav');
      } else {
        // Start recording
        isRecordingAudio = true;
        _recordingDuration = Duration.zero;

        // Start timer
        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += Duration(seconds: 1);
          });
        });

        // TODO: Implement actual audio recording start logic
        _showInfo('Audio recording started (placeholder)');
      }
    });
  }

  // FIX: Added missing method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }

  InputDecoration _buildInputDecoration(String hint, {String? errorText}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : Colors.teal,
          width: 2,
        ),
      ),
      errorText: errorText,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  // Real-time validation methods
  void _validateFullName(String value) {
    setState(() {
      if (value.isEmpty) {
        fullNameError = 'Full name is required';
      } else if (value.length < 3) {
        fullNameError = 'Full name must be at least 3 characters';
      } else {
        fullNameError = null;
      }
    });
  }

  void _validateId(String value) {
    setState(() {
      idError = value.isEmpty ? 'ID is required' : null;
    });
  }

  void _validateAddress(String value) {
    setState(() {
      addressError = value.isEmpty ? 'Address is required' : null;
    });
  }

  void _validateMobile(String value) {
    setState(() {
      if (value.isEmpty) {
        mobileError = 'Mobile number is required';
      } else if (!RegExp(
        r'^[0-9]{7,15}$',
      ).hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
        mobileError = 'Invalid mobile number';
      } else {
        mobileError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailError = 'Email is required';
      } else if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(value)) {
        emailError = 'Invalid email format';
      } else {
        emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = 'Password is required';
      } else if (value.length < 8) {
        passwordError = 'Password must be at least 8 characters';
      } else if (!value.contains(RegExp(r'[A-Z]'))) {
        passwordError = 'Must include at least one capital letter';
      } else if (!value.contains(RegExp(r'[0-9]'))) {
        passwordError = 'Must include at least one number';
      } else if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        passwordError = 'Must include at least one special character';
      } else {
        passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
      } else if (value != passwordCtrl.text) {
        confirmPasswordError = 'Passwords do not match';
      } else {
        confirmPasswordError = null;
      }
    });
  }

  void _validateClinicName(String value) {
    setState(() {
      clinicNameError = value.isEmpty ? 'Clinic name is required' : null;
    });
  }

  void _validateClinicAddress(String value) {
    setState(() {
      clinicAddressError = value.isEmpty ? 'Clinic address is required' : null;
    });
  }

  void _validateClinicPhone(String value) {
    setState(() {
      if (value.isEmpty) {
        clinicPhoneError = 'Clinic phone is required';
      } else if (!RegExp(
        r'^[0-9]{7,15}$',
      ).hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
        clinicPhoneError = 'Invalid phone number';
      } else {
        clinicPhoneError = null;
      }
    });
  }

  void _validateDiagnosis(String value) {
    setState(() {
      diagnosisError = value.isEmpty ? 'Please enter medical background' : null;
    });
  }

  void _validateOperations(String value) {
    setState(() {
      operationsError = value.isEmpty ? 'Please enter surgery history' : null;
    });
  }

  void _validateMedications(String value) {
    setState(() {
      medicationsError = value.isEmpty
          ? 'Please enter current medications'
          : null;
    });
  }

  void _validateCertificate() {
    setState(() {
      certificateError = certificateFile == null
          ? 'Certificate is required'
          : null;
    });
  }

  void _validateLicense() {
    setState(() {
      licenseError = licenseFile == null ? 'License is required' : null;
    });
  }

  void _validateProfilePhoto() {
    setState(() {
      profilePhotoError = pickedProfilePhoto == null
          ? 'Profile photo is required'
          : null;
    });
  }

  // Validate all required fields at submission time
  // Validate all fields and populate error states (called on signup click)
  bool validateAllFieldsAndShowErrors() {
    // Validate all fields to populate error states
    _validateFullName(fullNameCtrl.text);
    _validateId(idCtrl.text);
    _validateAddress(addressCtrl.text);
    _validateMobile(mobileCtrl.text);
    _validateEmail(emailCtrl.text);
    _validatePassword(passwordCtrl.text);
    _validateConfirmPassword(confirmPasswordCtrl.text);
    _validateClinicName(clinicNameCtrl.text);
    _validateClinicAddress(clinicAddressCtrl.text);
    _validateClinicPhone(clinicPhoneCtrl.text);
    _validateDiagnosis(diagnosisCtrl.text);
    _validateOperations(operationsCtrl.text);
    _validateMedications(medicationsCtrl.text);
    _validateCertificate();
    _validateLicense();
    _validateProfilePhoto();

    // Check if date of birth is selected
    if (selectedDateOfBirth == null) {
      setState(() {
        dateOfBirthError = 'Date of birth is required';
      });
    }

    // Check if all required dropdowns have values (they should have defaults but check anyway)
    if (selectedMainSpeciality == null || selectedDegree == null) {
      _showError('Please select Main Speciality and Scientific Degree');
      return false;
    }

    // Check if there are any errors
    if (fullNameError != null ||
        idError != null ||
        addressError != null ||
        mobileError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        clinicNameError != null ||
        clinicAddressError != null ||
        clinicPhoneError != null ||
        diagnosisError != null ||
        operationsError != null ||
        medicationsError != null ||
        certificateError != null ||
        licenseError != null ||
        profilePhotoError != null ||
        dateOfBirthError != null) {
      _showError('Please fix all errors before signing up');
      return false;
    }

    return true;
  }

  bool validateAllRequiredFields() {
    if (fullNameCtrl.text.isEmpty || fullNameCtrl.text.length < 3) {
      _showError('Full Name must be at least 3 characters');
      return false;
    }
    if (idCtrl.text.isEmpty) {
      _showError('ID Number is required');
      return false;
    }
    if (addressCtrl.text.isEmpty) {
      _showError('Address is required');
      return false;
    }
    if (mobileCtrl.text.isEmpty) {
      _showError('Mobile Number is required');
      return false;
    }
    if (emailCtrl.text.isEmpty) {
      _showError('Email is required');
      return false;
    }
    if (passwordCtrl.text.isEmpty) {
      _showError('Password is required');
      return false;
    }
    if (confirmPasswordCtrl.text.isEmpty) {
      _showError('Confirm Password is required');
      return false;
    }
    if (clinicNameCtrl.text.isEmpty) {
      _showError('Clinic Name is required');
      return false;
    }
    if (clinicAddressCtrl.text.isEmpty) {
      _showError('Clinic Address is required');
      return false;
    }
    if (clinicPhoneCtrl.text.isEmpty) {
      _showError('Clinic Phone is required');
      return false;
    }
    if (diagnosisCtrl.text.isEmpty) {
      _showError('Diagnosis/Medical Background is required');
      return false;
    }
    if (operationsCtrl.text.isEmpty) {
      _showError('Previous Operations is required');
      return false;
    }
    if (medicationsCtrl.text.isEmpty) {
      _showError('Medications is required');
      return false;
    }
    if (certificateFile == null) {
      _showError('Certificate is required');
      return false;
    }
    if (licenseFile == null) {
      _showError('License is required');
      return false;
    }
    if (pickedProfilePhoto == null) {
      _showError('Profile Photo is required');
      return false;
    }
    if (selectedMainSpeciality == null) {
      _showError('Main Speciality is required');
      return false;
    }
    if (selectedDegree == null) {
      _showError('Scientific Degree is required');
      return false;
    }
    return true;
  }

  // Helper method to show error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Helper method to show success messages
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Helper method to show info messages
  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }

  // Helper: Extract phone code from formatted country code (e.g., "🇸🇦 +966" -> "+966")
  String _getPhoneCode(String countryCodeWithFlag) {
    final match = RegExp(r'\+\d+').firstMatch(countryCodeWithFlag);
    return match?.group(0) ?? '+966';
  }

  // Firebase authentication function with Firestore & 2FA implementation
  Future<void> createUserWithEmailAndPassword() async {
    try {
      setState(() => isLoadingAuth = true);

      // Validate all fields and show all errors at once
      if (!validateAllFieldsAndShowErrors()) {
        setState(() => isLoadingAuth = false);
        return;
      }

      // Validate date of birth is selected
      if (selectedDateOfBirth == null) {
        setState(() {
          dateOfBirthError = 'Date of birth is required';
          isLoadingAuth = false;
        });
        _showError('Date of Birth is required');
        return;
      }

      // Parse comma-separated medical fields
      final List<String> medications = backend.parseCommaSeparatedString(
        medicationsCtrl.text,
      );
      final List<String> diagnosis = backend.parseCommaSeparatedString(
        diagnosisCtrl.text,
      );
      final List<String> operations = backend.parseCommaSeparatedString(
        operationsCtrl.text,
      );

      // Convert profile photo to File if selected
      File? profilePhotoFile;
      if (pickedProfilePhoto != null) {
        profilePhotoFile = File(pickedProfilePhoto!.path);
      }

      // Convert certificate file to File if selected
      File? certificatePhotoFile;
      if (certificateFile != null) {
        certificatePhotoFile = File(certificateFile!.path);
      }

      // Convert license file to File if selected
      File? licensePhotoFile;
      if (licenseFile != null) {
        licensePhotoFile = File(licenseFile!.path);
      }

      // Call backend complete signup function
      await backend.completeSignup(
        email: emailCtrl.text,
        password: passwordCtrl.text,
        fullName: fullNameCtrl.text,
        idNumber: idCtrl.text,
        idType: selectedIdType ?? 'National ID',
        gender: selectedGender ?? 'Male',
        dateOfBirth: selectedDateOfBirth,
        address: addressCtrl.text,
        city: selectedCity ?? '',
        region: selectedRegion ?? '',
        mobileNumber: mobileCtrl.text,
        countryCode: _getPhoneCode(selectedCountryCode ?? '+966'),
        clinicName: clinicNameCtrl.text,
        clinicAddress: clinicAddressCtrl.text,
        clinicPhone: clinicPhoneCtrl.text,
        mainSpeciality: selectedMainSpeciality ?? '',
        subSpeciality: selectedSubSpeciality ?? '',
        degree: selectedDegree ?? '',
        medications: medications,
        diagnosis: diagnosis,
        operations: operations,
        profilePhotoFile: profilePhotoFile,
        certificateFile: certificatePhotoFile,
        licenseFile: licensePhotoFile,
        audioFile: recordedAudioFile,
        videoFile: recordedVideoFile,
        onSuccess: (message) {
          _showSuccess('Signup completed successfully!');
          _clearForm();
          Navigator.pushReplacementNamed(context, '/home');
        },
        onError: (error) {
          _showError(error);
        },
      );
    } catch (e) {
      _showError('Unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingAuth = false);
      }
    }
  }

  // Clear form after successful signup
  void _clearForm() {
    fullNameCtrl.clear();
    idCtrl.clear();
    addressCtrl.clear();
    mobileCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    clinicNameCtrl.clear();
    clinicAddressCtrl.clear();
    clinicPhoneCtrl.clear();
    diagnosisCtrl.clear();
    operationsCtrl.clear();
    medicationsCtrl.clear();
    setState(() {
      pickedProfilePhoto = null;
      certificateFile = null;
      licenseFile = null;
      recordedAudioFile = null;
      recordedVideoFile = null;
      selectedDateOfBirth = null;
      isRecordingAudio = false;
      _recordingDuration = Duration.zero;
      _recordingTimer?.cancel();
    });
  }

  // UI Helper: Pick Profile Photo
  Future<void> pickProfilePhoto() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        pickedProfilePhoto = image;
        _validateProfilePhoto();
      });
      _showSuccess('Profile photo selected');
    }
  }

  // UI Helper: Pick Certificate
  Future<void> pickCertificate() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        certificateFile = image;
        _validateCertificate();
      });
      _showSuccess('Certificate uploaded');
    }
  }

  // UI Helper: Pick License
  Future<void> pickLicense() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        licenseFile = image;
        _validateLicense();
      });
      _showSuccess('License uploaded');
    }
  }

  // UI Helper: Show Date Picker
  Future<void> selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
        dateOfBirthError = null; // Clear error when date is selected
      });
    }
  }

  // UI Helper: Load and search clinics
  Future<void> loadAndSearchClinics(String query) async {
    // TODO: Will be implemented in backend
    // For now, we'll filter the local list
    if (query.isEmpty) {
      setState(() => filteredClinics = availableClinics);
    } else {
      setState(() {
        filteredClinics = availableClinics
            .where(
              (clinic) =>
                  clinic['name']!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  // UI Helper: Select clinic from dropdown
  void selectClinic(Map<String, String> clinic) {
    setState(() {
      clinicNameCtrl.text = clinic['name'] ?? '';
      clinicAddressCtrl.text = clinic['address'] ?? '';
      clinicPhoneCtrl.text = clinic['phone'] ?? '';
      showClinicDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  LanguageSwitch(
                    isArabic: isArabic,
                    onChanged: (val) => setState(() => isArabic = val),
                  ),
                  const SizedBox(height: 20),
                  // Profile Photo Picker
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
                          ? ClipOval(
                              child: Image.file(
                                File(pickedProfilePhoto!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.teal,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (profilePhotoError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        profilePhotoError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Personal Info Section
                  NestedSection(
                    title: 'Personal Info',
                    children: [
                      const SizedBox(height: 12),
                      StyledLabel(text: 'Full Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: fullNameCtrl,
                        onChanged: _validateFullName,
                        decoration: _buildInputDecoration(
                          'Enter your full name',
                          errorText: fullNameError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'ID Type'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: idTypes,
                        initialValue: selectedIdType,
                        onChanged: (val) =>
                            setState(() => selectedIdType = val),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: idCtrl,
                        onChanged: _validateId,
                        decoration: _buildInputDecoration(
                          'Enter your ID number',
                          errorText: idError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Gender'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedGender = 'Male'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedGender == 'Male'
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                    width: selectedGender == 'Male' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: selectedGender == 'Male'
                                          ? Colors.teal
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Male'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedGender = 'Female'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedGender == 'Female'
                                        ? Colors.teal
                                        : Colors.grey.shade300,
                                    width: selectedGender == 'Female' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: selectedGender == 'Female'
                                          ? Colors.teal
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Female'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Address'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressCtrl,
                        onChanged: _validateAddress,
                        decoration: _buildInputDecoration(
                          'Enter your address',
                          errorText: addressError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'City'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: cities,
                        initialValue: selectedCity,
                        onChanged: (val) => setState(() => selectedCity = val),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Region'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: regions,
                        initialValue: selectedRegion,
                        onChanged: (val) =>
                            setState(() => selectedRegion = val),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Mobile'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: StyledDropdown(
                              items: countryCodes,
                              initialValue: selectedCountryCode,
                              onChanged: (val) =>
                                  setState(() => selectedCountryCode = val),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: mobileCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: _validateMobile,
                              decoration: _buildInputDecoration(
                                'Mobile number',
                                errorText: mobileError,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailCtrl,
                        onChanged: _validateEmail,
                        decoration: _buildInputDecoration(
                          'Enter your email',
                          errorText: emailError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        onChanged: (value) {
                          _validatePassword(value);
                          _validateConfirmPassword(confirmPasswordCtrl.text);
                        },
                        decoration: _buildInputDecoration(
                          'Enter password',
                          errorText: passwordError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Confirm Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmPasswordCtrl,
                        obscureText: true,
                        onChanged: _validateConfirmPassword,
                        decoration: _buildInputDecoration(
                          'Confirm password',
                          errorText: confirmPasswordError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Date of Birth'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: selectDateOfBirth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(
                              color: dateOfBirthError != null
                                  ? Colors.red
                                  : Colors.grey,
                              width: dateOfBirthError != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDateOfBirth != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(selectedDateOfBirth!)
                                    : 'Select your date of birth',
                                style: TextStyle(
                                  color: selectedDateOfBirth != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                ),
                              ),
                              Icon(Icons.calendar_today, color: Colors.teal),
                            ],
                          ),
                        ),
                      ),
                      if (dateOfBirthError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateOfBirthError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Work Info Section
                  NestedSection(
                    title: 'Work Info',
                    children: [
                      const SizedBox(height: 12),
                      StyledLabel(text: 'Main Speciality'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: mainSpecialties,
                        initialValue: selectedMainSpeciality,
                        onChanged: (val) =>
                            setState(() => selectedMainSpeciality = val),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Sub Speciality'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: subSpecialties,
                        initialValue: selectedSubSpeciality,
                        onChanged: (val) =>
                            setState(() => selectedSubSpeciality = val),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Scientific Degree'),
                      const SizedBox(height: 8),
                      StyledDropdown(
                        items: degrees,
                        initialValue: selectedDegree,
                        onChanged: (val) =>
                            setState(() => selectedDegree = val),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Clinic Name'),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          TextField(
                            controller: clinicNameCtrl,
                            onChanged: (value) {
                              _validateClinicName(value);
                              loadAndSearchClinics(value);
                            },
                            onTap: () {
                              setState(() => showClinicDropdown = true);
                              loadAndSearchClinics(clinicNameCtrl.text);
                            },
                            decoration: _buildInputDecoration(
                              'Search or enter clinic name',
                              errorText: clinicNameError,
                            ),
                          ),
                          if (showClinicDropdown && filteredClinics.isNotEmpty)
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filteredClinics.length,
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Clinic Address'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: clinicAddressCtrl,
                        onChanged: _validateClinicAddress,
                        decoration: _buildInputDecoration(
                          'Enter clinic address',
                          errorText: clinicAddressError,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Clinic Phone'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: StyledDropdown(
                              items: countryCodes,
                              initialValue: selectedClinicCountryCode,
                              onChanged: (val) => setState(
                                () => selectedClinicCountryCode = val,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: clinicPhoneCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: _validateClinicPhone,
                              decoration: _buildInputDecoration(
                                'Enter clinic phone',
                                errorText: clinicPhoneError,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Upload Certificate'),
                      const SizedBox(height: 8),
                      if (certificateError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            certificateError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: pickCertificate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: certificateError != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: certificateError != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: certificateFile != null
                                ? Colors.teal.shade50
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  certificateFile != null
                                      ? Icons.check_circle
                                      : Icons.cloud_upload,
                                  size: 32,
                                  color: certificateFile != null
                                      ? Colors.green
                                      : Colors.teal,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  certificateFile != null
                                      ? 'Certificate uploaded'
                                      : 'Tap to upload certificate',
                                  style: TextStyle(
                                    color: certificateFile != null
                                        ? Colors.green
                                        : Colors.teal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledLabel(text: 'Upload License'),
                      const SizedBox(height: 8),
                      if (licenseError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            licenseError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: pickLicense,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: licenseError != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: licenseError != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: licenseFile != null
                                ? Colors.teal.shade50
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  licenseFile != null
                                      ? Icons.check_circle
                                      : Icons.cloud_upload,
                                  size: 32,
                                  color: licenseFile != null
                                      ? Colors.green
                                      : Colors.teal,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  licenseFile != null
                                      ? 'License uploaded'
                                      : 'Tap to upload license',
                                  style: TextStyle(
                                    color: licenseFile != null
                                        ? Colors.green
                                        : Colors.teal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Medical Info Section
                  NestedSection(
                    title: 'Medical Info',
                    children: [
                      const SizedBox(height: 12),

                      // Diagnosis Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const StyledLabel(text: 'Diagnosis')],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: diagnosisCtrl,
                        onChanged: _validateDiagnosis,
                        decoration: _buildInputDecoration(
                          'Enter diagnoses (comma-separated)',
                          errorText: diagnosisError,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Previous Operations Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StyledLabel(text: 'Previous Operations'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: operationsCtrl,
                        onChanged: _validateOperations,
                        decoration: _buildInputDecoration(
                          'Enter operations (comma-separated)',
                          errorText: operationsError,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medications Field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const StyledLabel(text: 'Medications')],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: medicationsCtrl,
                        onChanged: _validateMedications,
                        decoration: _buildInputDecoration(
                          'Enter medications (comma-separated)',
                          errorText: medicationsError,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ==========================================
                      // AUDIO/VIDEO RECORDING SECTION
                      // ==========================================
                      StyledLabel(text: 'Record Audio/Video'),
                      const SizedBox(height: 8),

                      // Audio Recording Button
                      GestureDetector(
                        onTap: _toggleAudioRecording,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isRecordingAudio
                                  ? Colors.red
                                  : Colors.grey.shade300,
                              width: isRecordingAudio ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isRecordingAudio
                                ? Colors.red[50]
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isRecordingAudio
                                    ? Icons.stop_circle
                                    : Icons.mic,
                                color: isRecordingAudio
                                    ? Colors.red
                                    : Colors.teal,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRecordingAudio
                                        ? 'Stop Recording'
                                        : 'Record Audio',
                                    style: TextStyle(
                                      color: isRecordingAudio
                                          ? Colors.red
                                          : Colors.teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (isRecordingAudio)
                                    Text(
                                      _formatDuration(_recordingDuration),
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Audio Recording Status Indicator
                      if (recordedAudioFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Audio recorded successfully',
                                        style: TextStyle(
                                          color: Colors.green[900],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        recordedAudioFile!.path.split('/').last,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () {
                                    setState(() => recordedAudioFile = null);
                                    _showInfo('Audio recording deleted');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Video Recording Button (Placeholder)
                      GestureDetector(
                        onTap: () {
                          _showInfo('Video recording feature coming soon');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                color: Colors.teal,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Record Video',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: isLoadingAuth
                ? const SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  )
                : StyledButton(
                    label: 'Sign Up',
                    color: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 14,
                    ),
                    onPressed: () {
                      // Call Firebase authentication
                      createUserWithEmailAndPassword();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
