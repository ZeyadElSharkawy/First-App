import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
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
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _hasRecordingPermission = false;

  // Clinic Search Variables
  List<Map<String, String>> availableClinics = [];
  List<Map<String, String>> filteredClinics = [];
  bool showClinicDropdown = false;
  int? currentSearchClinicIndex; // Track which clinic row is being searched

  // Personal Info Controllers
  final fullNameCtrl = TextEditingController();
  final idCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // 1. DYNAMIC LISTS FOR MULTIPLE ENTRIES
  List<Map<String, TextEditingController>> clinicRows = [];
  List<TextEditingController> diagnosisRows = [TextEditingController()];
  List<TextEditingController> operationsRows = [TextEditingController()];
  List<TextEditingController> medicationsRows = [TextEditingController()];

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
  List<String?> clinicNameErrors = [];
  List<String?> clinicAddressErrors = [];
  List<String?> clinicPhoneErrors = [];
  List<String?> diagnosisErrors = [];
  List<String?> operationsErrors = [];
  List<String?> medicationsErrors = [];
  String? certificateError;
  String? licenseError;
  String? profilePhotoError;
  String? audioRecordingError;  // Add this line


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
    
    // Set default values for personal info dropdowns with safe checks
    selectedCity = cities.isNotEmpty ? cities.first : 'Riyadh';
    selectedRegion = regions.isNotEmpty ? regions.first : 'Region 1';

    // Initialize with one empty clinic row
    _addClinicRow();
    
    // Initialize medical info rows with safe defaults
    diagnosisRows = [TextEditingController()];
    operationsRows = [TextEditingController()];
    medicationsRows = [TextEditingController()];
    
    // Initialize error lists
    diagnosisErrors = [null];
    operationsErrors = [null];
    medicationsErrors = [null];
    
    _loadClinicsFromBackend();
    _checkRecordingPermission();
  }

  void _addClinicRow() {
    setState(() {
      clinicRows.add({
        'name': TextEditingController(),
        'address': TextEditingController(),
        'phone': TextEditingController(),
      });
      clinicNameErrors.add(null);
      clinicAddressErrors.add(null);
      clinicPhoneErrors.add(null);
    });
  }

  void _addDiagnosisRow() {
    setState(() {
      diagnosisRows.add(TextEditingController());
      diagnosisErrors.add(null);
    });
  }

  void _addOperationsRow() {
    setState(() {
      operationsRows.add(TextEditingController());
      operationsErrors.add(null);
    });
  }

  void _addMedicationsRow() {
    setState(() {
      medicationsRows.add(TextEditingController());
      medicationsErrors.add(null);
    });
  }

  void _removeClinicRow(int index) {
    setState(() {
      clinicRows[index]['name']!.dispose();
      clinicRows[index]['address']!.dispose();
      clinicRows[index]['phone']!.dispose();
      clinicRows.removeAt(index);
      clinicNameErrors.removeAt(index);
      clinicAddressErrors.removeAt(index);
      clinicPhoneErrors.removeAt(index);
    });
  }

  void _removeDiagnosisRow(int index) {
    setState(() {
      diagnosisRows[index].dispose();
      diagnosisRows.removeAt(index);
      diagnosisErrors.removeAt(index);
    });
  }

  void _removeOperationsRow(int index) {
    setState(() {
      operationsRows[index].dispose();
      operationsRows.removeAt(index);
      operationsErrors.removeAt(index);
    });
  }

  void _removeMedicationsRow(int index) {
    setState(() {
      medicationsRows[index].dispose();
      medicationsRows.removeAt(index);
      medicationsErrors.removeAt(index);
    });
  }

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

  // Check recording permission
  Future<void> _checkRecordingPermission() async {
    final permission = await Permission.microphone.request();
    setState(() {
      _hasRecordingPermission = permission == PermissionStatus.granted;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    // Stop recording timer if active
    _recordingTimer?.cancel();

    // Dispose audio recorder
    _audioRecorder.dispose();

    // Dispose all controllers
    fullNameCtrl.dispose();
    idCtrl.dispose();
    addressCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    
    // Dispose clinic controllers
    for (var row in clinicRows) {
      row['name']!.dispose();
      row['address']!.dispose();
      row['phone']!.dispose();
    }
    
    // Dispose medical info controllers
    for (var ctrl in diagnosisRows) {
      ctrl.dispose();
    }
    for (var ctrl in operationsRows) {
      ctrl.dispose();
    }
    for (var ctrl in medicationsRows) {
      ctrl.dispose();
    }
    
    super.dispose();
  }

  // Audio Recording Methods
  Future<void> _toggleAudioRecording() async {
    if (!_hasRecordingPermission) {
      await _checkRecordingPermission();
      if (!_hasRecordingPermission) {
        _showError('Microphone permission is required for recording');
        return;
      }
    }

    setState(() {
      if (isRecordingAudio) {
        // Stop recording
        isRecordingAudio = false;
        _recordingTimer?.cancel();
        _recordingDuration = Duration.zero;
        _stopAudioRecording();
      } else {
        // Start recording
        isRecordingAudio = true;
        _recordingDuration = Duration.zero;
        
        // Start recording timer
        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += Duration(seconds: 1);
          });
        });
        
        // Start actual recording
        _startAudioRecording();
      }
    });
  }

  Future<void> _startAudioRecording() async {
    try {
      // Get app directory for saving recordings
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // Configure recording settings
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      // Start recording
      await _audioRecorder.start(config, path: path);
      
      
      
      _showInfo('Recording started...');
      
    } catch (e) {
      _showError('Failed to start recording: $e');
      setState(() {
        isRecordingAudio = false;
        _recordingTimer?.cancel();
      });
    }
  }

  Future<void> _stopAudioRecording() async {
  try {
    final path = await _audioRecorder.stop();
    
    if (path != null) {
      setState(() {
        recordedAudioFile = File(path);
        audioRecordingError = null; // Clear error when recording is successful
      });
      _showSuccess('Recording saved successfully');
    } else {
      setState(() {
        audioRecordingError = 'Recording failed - no file created';
      });
      _showError('Recording failed - no file created');
    }
    
  } catch (e) {
    setState(() {
      audioRecordingError = 'Failed to stop recording: $e';
    });
    _showError('Failed to stop recording: $e');
  } finally {
    setState(() {
      isRecordingAudio = false;
      _recordingTimer?.cancel();
    });
  }
}

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
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

  void _validateClinicName(int index, String value) {
    setState(() {
      if (value.isEmpty) {
        clinicNameErrors[index] = 'Clinic name is required';
      } else {
        clinicNameErrors[index] = null;
      }
    });
  }

  void _validateClinicAddress(int index, String value) {
    setState(() {
      clinicAddressErrors[index] = value.isEmpty ? 'Clinic address is required' : null;
    });
  }

  void _validateClinicPhone(int index, String value) {
    setState(() {
      if (value.isEmpty) {
        clinicPhoneErrors[index] = 'Clinic phone is required';
      } else if (!RegExp(
        r'^[0-9]{7,15}$',
      ).hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
        clinicPhoneErrors[index] = 'Invalid phone number';
      } else {
        clinicPhoneErrors[index] = null;
      }
    });
  }

  void _validateDiagnosis(int index, String value) {
    setState(() {
      diagnosisErrors[index] = value.isEmpty ? 'Please enter medical background' : null;
    });
  }

  void _validateOperations(int index, String value) {
    setState(() {
      operationsErrors[index] = value.isEmpty ? 'Please enter surgery history' : null;
    });
  }

  void _validateMedications(int index, String value) {
    setState(() {
      medicationsErrors[index] = value.isEmpty
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

  void _validateAudioRecording() {
  setState(() {
    audioRecordingError = recordedAudioFile == null
        ? 'Audio recording is required'
        : null;
  });
}

  // Validate all required fields at submission time
  bool validateAllFieldsAndShowErrors() {
    // Validate all fields to populate error states
    _validateFullName(fullNameCtrl.text);
    _validateId(idCtrl.text);
    _validateAddress(addressCtrl.text);
    _validateMobile(mobileCtrl.text);
    _validateEmail(emailCtrl.text);
    _validatePassword(passwordCtrl.text);
    _validateConfirmPassword(confirmPasswordCtrl.text);
    

    
    // Validate clinic rows
    for (int i = 0; i < clinicRows.length; i++) {
      _validateClinicName(i, clinicRows[i]['name']!.text);
      _validateClinicAddress(i, clinicRows[i]['address']!.text);
      _validateClinicPhone(i, clinicRows[i]['phone']!.text);
    }
    
    // Validate medical info rows
    for (int i = 0; i < diagnosisRows.length; i++) {
      _validateDiagnosis(i, diagnosisRows[i].text);
    }
    for (int i = 0; i < operationsRows.length; i++) {
      _validateOperations(i, operationsRows[i].text);
    }
    for (int i = 0; i < medicationsRows.length; i++) {
      _validateMedications(i, medicationsRows[i].text);
    }
    
    _validateCertificate();
    _validateLicense();
    _validateProfilePhoto();
    _validateAudioRecording();

    // Check if date of birth is selected
    if (selectedDateOfBirth == null) {
      setState(() {
        dateOfBirthError = 'Date of birth is required';
      });
    }

    // Check if all required dropdowns have values
    if (selectedMainSpeciality == null || selectedDegree == null) {
      _showError('Please select Main Speciality and Scientific Degree');
      return false;
    }

    // Check if there are any errors
    bool hasErrors = fullNameError != null ||
        idError != null ||
        addressError != null ||
        mobileError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null ||
        certificateError != null ||
        licenseError != null ||
        profilePhotoError != null ||
        dateOfBirthError != null ||
        audioRecordingError != null;
    
    // Check clinic errors
    for (var error in clinicNameErrors) {
      if (error != null) hasErrors = true;
    }
    for (var error in clinicAddressErrors) {
      if (error != null) hasErrors = true;
    }
    for (var error in clinicPhoneErrors) {
      if (error != null) hasErrors = true;
    }
    
    // Check medical info errors
    for (var error in diagnosisErrors) {
      if (error != null) hasErrors = true;
    }
    for (var error in operationsErrors) {
      if (error != null) hasErrors = true;
    }
    for (var error in medicationsErrors) {
      if (error != null) hasErrors = true;
    }

    if (hasErrors) {
      _showError('Please fix all errors before signing up');
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

  // UI Helper for Multiple Medical Fields
  Widget _buildDynamicList({
    required String label,
    required List<TextEditingController> controllers,
    required List<String?> errors,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required String hint,
    required Function(int, String) onValidate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StyledLabel(text: label),
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.teal), 
              onPressed: onAdd
            ),
          ],
        ),
        ...controllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    onChanged: (value) => onValidate(index, value),
                    decoration: _buildInputDecoration(
                      hint,
                      errorText: errors[index],
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => onRemove(index),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // UPDATED CLINIC UI SECTION
  Widget _buildClinicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StyledLabel(text: 'Work Clinics'),
            IconButton(
              icon: Icon(Icons.add_box, color: Colors.teal, size: 30), 
              onPressed: _addClinicRow
            ),
          ],
        ),
        ...clinicRows.asMap().entries.map((entry) {
          int index = entry.key;
          var row = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Clinic #${index + 1}", 
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                      ),
                      if (clinicRows.length > 1)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeClinicRow(index),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: row['name'],
                    onChanged: (val) {
                      _validateClinicName(index, val);
                      _filterClinics(val, index);
                    },
                    onTap: () {
                      setState(() {
                        showClinicDropdown = true;
                        currentSearchClinicIndex = index;
                      });
                      _filterClinics(row['name']!.text, index);
                    },
                    decoration: _buildInputDecoration(
                      'Search or enter clinic name',
                      errorText: clinicNameErrors[index],
                    ),
                  ),
                  
                  // Simple Dropdown for existing clinics
                  if (showClinicDropdown && currentSearchClinicIndex == index && filteredClinics.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredClinics.length,
                        itemBuilder: (context, i) => ListTile(
                          title: Text(filteredClinics[i]['name']!),
                          subtitle: Text(filteredClinics[i]['address']!),
                          onTap: () {
                            setState(() {
                              row['name']!.text = filteredClinics[i]['name']!;
                              row['address']!.text = filteredClinics[i]['address']!;
                              row['phone']!.text = filteredClinics[i]['phone']!;
                              showClinicDropdown = false;
                              currentSearchClinicIndex = null;
                            });
                            _validateClinicName(index, filteredClinics[i]['name']!);
                            _validateClinicAddress(index, filteredClinics[i]['address']!);
                            _validateClinicPhone(index, filteredClinics[i]['phone']!);
                          },
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 12),
                  TextField(
                    controller: row['address'],
                    onChanged: (val) => _validateClinicAddress(index, val),
                    decoration: _buildInputDecoration(
                      'Clinic Address',
                      errorText: clinicAddressErrors[index],
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: row['phone'],
                    onChanged: (val) => _validateClinicPhone(index, val),
                    decoration: _buildInputDecoration(
                      'Clinic Phone',
                      errorText: clinicPhoneErrors[index],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Filter clinics based on search query
  void _filterClinics(String query, int index) {
    if (query.isEmpty) {
      setState(() => filteredClinics = availableClinics);
    } else {
      setState(() {
        filteredClinics = availableClinics
            .where((clinic) => clinic['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  // Firebase authentication function
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

      // Convert clinic rows to list of maps
      List<Map<String, String>> clinics = [];
      for (var row in clinicRows) {
        clinics.add({
          'name': row['name']!.text,
          'address': row['address']!.text,
          'phone': row['phone']!.text,
        });
      }

      // Convert medical info to lists
      List<String> medications = [];
      for (var ctrl in medicationsRows) {
        if (ctrl.text.isNotEmpty) {
          medications.add(ctrl.text);
        }
      }

      List<String> diagnosis = [];
      for (var ctrl in diagnosisRows) {
        if (ctrl.text.isNotEmpty) {
          diagnosis.add(ctrl.text);
        }
      }

      List<String> operations = [];
      for (var ctrl in operationsRows) {
        if (ctrl.text.isNotEmpty) {
          operations.add(ctrl.text);
        }
      }

      // Convert files to File objects
      File? profilePhotoFile;
      if (pickedProfilePhoto != null) {
        profilePhotoFile = File(pickedProfilePhoto!.path);
      }

      File? certificatePhotoFile;
      if (certificateFile != null) {
        certificatePhotoFile = File(certificateFile!.path);
      }

      File? licensePhotoFile;
      if (licenseFile != null) {
        licensePhotoFile = File(licenseFile!.path);
      }

      // Call backend complete signup function with updated parameters
      await backend.completeSignup(
        email: emailCtrl.text,
        password: passwordCtrl.text,
        fullName: fullNameCtrl.text,
        idNumber: idCtrl.text,
        idType: selectedIdType ?? 'National ID',
        gender: selectedGender ?? 'Male',
        dateOfBirth: selectedDateOfBirth,
        address: addressCtrl.text,
        city: selectedCity ?? (cities.isNotEmpty ? cities.first : 'Riyadh'), // SAFE FALLBACK
        region: selectedRegion ?? (regions.isNotEmpty ? regions.first : 'Region 1'), // SAFE FALLBACK
        mobileNumber: mobileCtrl.text,
        countryCode: _getPhoneCode(selectedCountryCode ?? '+966'),
        clinics: clinics, // Now passing list of clinics
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
    
    // Clear clinic rows
    for (var row in clinicRows) {
      row['name']!.clear();
      row['address']!.clear();
      row['phone']!.clear();
    }
    
    // Clear medical info rows
    for (var ctrl in diagnosisRows) {
      ctrl.clear();
    }
    for (var ctrl in operationsRows) {
      ctrl.clear();
    }
    for (var ctrl in medicationsRows) {
      ctrl.clear();
    }
    
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
      
      // Reset to initial state
      clinicRows.clear();
      diagnosisRows.clear();
      operationsRows.clear();
      medicationsRows.clear();
      
      // Add initial rows
      _addClinicRow();
      diagnosisRows.add(TextEditingController());
      operationsRows.add(TextEditingController());
      medicationsRows.add(TextEditingController());
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

Future<void> selectDateOfBirth() async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime(1990), // Changed from 2000 to 1990
    firstDate: DateTime(1950),
    lastDate: DateTime(2001), // Changed from DateTime.now() to 2001
  );
  if (picked != null) {
    setState(() {
      selectedDateOfBirth = picked;
      dateOfBirthError = null;
    });
  }
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
                      
                      // Updated Clinic Section
                      _buildClinicSection(),
                      
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

                      // Diagnosis Field - Updated with dynamic list
                      _buildDynamicList(
                        label: 'Diagnosis',
                        controllers: diagnosisRows,
                        errors: diagnosisErrors,
                        onAdd: _addDiagnosisRow,
                        onRemove: _removeDiagnosisRow,
                        hint: 'Enter medical background',
                        onValidate: _validateDiagnosis,
                      ),

                      const SizedBox(height: 16),

                      // Previous Operations Field - Updated with dynamic list
                      _buildDynamicList(
                        label: 'Previous Operations',
                        controllers: operationsRows,
                        errors: operationsErrors,
                        onAdd: _addOperationsRow,
                        onRemove: _removeOperationsRow,
                        hint: 'Enter surgery history',
                        onValidate: _validateOperations,
                      ),

                      const SizedBox(height: 16),

                      // Medications Field - Updated with dynamic list
                      _buildDynamicList(
                        label: 'Medications',
                        controllers: medicationsRows,
                        errors: medicationsErrors,
                        onAdd: _addMedicationsRow,
                        onRemove: _removeMedicationsRow,
                        hint: 'Enter current medications',
                        onValidate: _validateMedications,
                      ),

                      const SizedBox(height: 20),

                      // ==========================================
                      // AUDIO RECORDING SECTION
                      // ==========================================
                      StyledLabel(text: 'Record Audio'),
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

                      // Audio Recording Error Display - MOVED INSIDE NestedSection
                      if (audioRecordingError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            audioRecordingError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 16),
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