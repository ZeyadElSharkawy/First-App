mixin AppLocale {
  static const String signIn = 'signIn';
  static const String signUp = 'signUp';
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String home = 'home';
  static const String settings = 'settings';
  static const String darkMode = 'darkMode';
  static const String language = 'language';
  static const String profile = 'profile';
  static const String signOut = 'signOut';
  
  // Home page strings
  static const String dashboard = 'dashboard';
  static const String clinicalRisks = 'clinicalRisks';
  static const String ovr = 'ovr';
  static const String staffRisk = 'staffRisk';
  static const String pcraIcra = 'pcraIcra';
  static const String kpis = 'kpis';
  static const String profileTapped = 'profileTapped';
  static const String navigatingTo = 'navigatingTo';
  
  // SignUp page strings
  static const String personalInfo = 'personalInfo';
  static const String workInfo = 'workInfo';
  static const String medicalInfo = 'medicalInfo';
  static const String fullName = 'fullName';
  static const String idType = 'idType';
  static const String gender = 'gender';
  static const String male = 'male';
  static const String female = 'female';
  static const String address = 'address';
  static const String city = 'city';
  static const String region = 'region';
  static const String mobile = 'mobile';
  static const String dateOfBirth = 'dateOfBirth';
  static const String mainSpeciality = 'mainSpeciality';
  static const String subSpeciality = 'subSpeciality';
  static const String scientificDegree = 'scientificDegree';
  static const String clinicName = 'clinicName';
  static const String clinicAddress = 'clinicAddress';
  static const String clinicPhone = 'clinicPhone';
  static const String uploadCertificate = 'uploadCertificate';
  static const String uploadLicense = 'uploadLicense';
  static const String diagnosis = 'diagnosis';
  static const String previousOperations = 'previousOperations';
  static const String medications = 'medications';
  static const String recordAudioVideo = 'recordAudioVideo';
  static const String addPhoto = 'addPhoto';
  static const String recordAudio = 'recordAudio';
  static const String recordVideo = 'recordVideo';
  static const String stopAudio = 'stopAudio';
  static const String stopVideo = 'stopVideo';
  
  // Placeholders
  static const String enterFullName = 'enterFullName';
  static const String enterIdNumber = 'enterIdNumber';
  static const String enterAddress = 'enterAddress';
  static const String mobileNumber = 'mobileNumber';
  static const String enterEmail = 'enterEmail';
  static const String enterPassword = 'enterPassword';
  static const String confirmPasswordPlaceholder = 'confirmPasswordPlaceholder';
  static const String selectDateOfBirth = 'selectDateOfBirth';
  static const String searchClinicName = 'searchClinicName';
  static const String enterClinicAddress = 'enterClinicAddress';
  static const String enterClinicPhone = 'enterClinicPhone';
  static const String enterDiagnoses = 'enterDiagnoses';
  static const String enterOperations = 'enterOperations';
  static const String enterMedications = 'enterMedications';
  static const String tapToUploadCertificate = 'tapToUploadCertificate';
  static const String tapToUploadLicense = 'tapToUploadLicense';
  static const String certificateUploaded = 'certificateUploaded';
  static const String licenseUploaded = 'licenseUploaded';

  static const Map<String, dynamic> EN = {
    signIn: 'Sign In',
    signUp: 'Sign Up',
    email: 'Email',
    password: 'Password',
    confirmPassword: 'Confirm Password',
    home: 'Home',
    settings: 'Settings',
    darkMode: 'Dark Mode',
    language: 'Language',
    profile: 'Profile',
    signOut: 'Sign Out',
    
    // Home page
    dashboard: 'Dashboard',
    clinicalRisks: 'Clinical &\nNon-clinical Risks',
    ovr: 'OVR',
    staffRisk: 'Staff Risk',
    pcraIcra: 'PCRA & ICRA',
    kpis: 'KPIS',
    profileTapped: 'Profile tapped',
    navigatingTo: 'Navigating to',
    
    // SignUp page
    personalInfo: 'Personal Info',
    workInfo: 'Work Info',
    medicalInfo: 'Medical Info',
    fullName: 'Full Name',
    idType: 'ID Type',
    gender: 'Gender',
    male: 'Male',
    female: 'Female',
    address: 'Address',
    city: 'City',
    region: 'Region',
    mobile: 'Mobile',
    dateOfBirth: 'Date of Birth',
    mainSpeciality: 'Main Speciality',
    subSpeciality: 'Sub Speciality',
    scientificDegree: 'Scientific Degree',
    clinicName: 'Clinic Name',
    clinicAddress: 'Clinic Address',
    clinicPhone: 'Clinic Phone',
    uploadCertificate: 'Upload Certificate',
    uploadLicense: 'Upload License',
    diagnosis: 'Diagnosis',
    previousOperations: 'Previous Operations',
    medications: 'Medications',
    recordAudioVideo: 'Record Audio/Video',
    addPhoto: 'Add Photo',
    recordAudio: 'Record Audio',
    recordVideo: 'Record Video',
    stopAudio: 'Stop Audio',
    stopVideo: 'Stop Video',
    
    // Placeholders
    enterFullName: 'Enter your full name',
    enterIdNumber: 'Enter your ID number',
    enterAddress: 'Enter your address',
    mobileNumber: 'Mobile number',
    enterEmail: 'Enter your email',
    enterPassword: 'Enter password',
    confirmPasswordPlaceholder: 'Confirm password',
    selectDateOfBirth: 'Select your date of birth',
    searchClinicName: 'Search or enter clinic name',
    enterClinicAddress: 'Enter clinic address',
    enterClinicPhone: 'Enter clinic phone',
    enterDiagnoses: 'Enter diagnoses (comma-separated)',
    enterOperations: 'Enter operations (comma-separated)',
    enterMedications: 'Enter medications (comma-separated)',
    tapToUploadCertificate: 'Tap to upload certificate',
    tapToUploadLicense: 'Tap to upload license',
    certificateUploaded: 'Certificate uploaded',
    licenseUploaded: 'License uploaded',
  };

  static const Map<String, dynamic> AR = {
    signIn: 'تسجيل الدخول',
    signUp: 'إنشاء حساب',
    email: 'البريد الإلكتروني',
    password: 'كلمة المرور',
    confirmPassword: 'تأكيد كلمة المرور',
    home: 'الرئيسية',
    settings: 'الإعدادات',
    darkMode: 'الوضع الداكن',
    language: 'اللغة',
    profile: 'الملف الشخصي',
    signOut: 'تسجيل الخروج',
    
    // Home page
    dashboard: 'لوحة التحكم',
    clinicalRisks: 'المخاطر السريرية\nوغير السريرية',
    ovr: 'التقييم الشامل',
    staffRisk: 'مخاطر الموظفين',
    pcraIcra: 'تقييم المخاطر',
    kpis: 'مؤشرات الأداء',
    profileTapped: 'تم النقر على الملف الشخصي',
    navigatingTo: 'الانتقال إلى',
    
    // SignUp page
    personalInfo: 'المعلومات الشخصية',
    workInfo: 'معلومات العمل',
    medicalInfo: 'المعلومات الطبية',
    fullName: 'الاسم الكامل',
    idType: 'نوع الهوية',
    gender: 'الجنس',
    male: 'ذكر',
    female: 'أنثى',
    address: 'العنوان',
    city: 'المدينة',
    region: 'المنطقة',
    mobile: 'الجوال',
    dateOfBirth: 'تاريخ الميلاد',
    mainSpeciality: 'التخصص الرئيسي',
    subSpeciality: 'التخصص الفرعي',
    scientificDegree: 'الدرجة العلمية',
    clinicName: 'اسم العيادة',
    clinicAddress: 'عنوان العيادة',
    clinicPhone: 'هاتف العيادة',
    uploadCertificate: 'تحميل الشهادة',
    uploadLicense: 'تحميل الترخيص',
    diagnosis: 'التشخيص',
    previousOperations: 'العمليات السابقة',
    medications: 'الأدوية',
    recordAudioVideo: 'تسجيل صوتي/فيديو',
    addPhoto: 'إضافة صورة',
    recordAudio: 'تسجيل صوتي',
    recordVideo: 'تسجيل فيديو',
    stopAudio: 'إيقاف التسجيل الصوتي',
    stopVideo: 'إيقاف تسجيل الفيديو',
    
    // Placeholders
    enterFullName: 'أدخل اسمك الكامل',
    enterIdNumber: 'أدخل رقم الهوية',
    enterAddress: 'أدخل عنوانك',
    mobileNumber: 'رقم الجوال',
    enterEmail: 'أدخل بريدك الإلكتروني',
    enterPassword: 'أدخل كلمة المرور',
    confirmPasswordPlaceholder: 'أكد كلمة المرور',
    selectDateOfBirth: 'اختر تاريخ ميلادك',
    searchClinicName: 'ابحث أو أدخل اسم العيادة',
    enterClinicAddress: 'أدخل عنوان العيادة',
    enterClinicPhone: 'أدخل هاتف العيادة',
    enterDiagnoses: 'أدخل التشخيصات (مفصولة بفواصل)',
    enterOperations: 'أدخل العمليات (مفصولة بفواصل)',
    enterMedications: 'أدخل الأدوية (مفصولة بفواصل)',
    tapToUploadCertificate: 'اضغط لتحميل الشهادة',
    tapToUploadLicense: 'اضغط لتحميل الترخيص',
    certificateUploaded: 'تم تحميل الشهادة',
    licenseUploaded: 'تم تحميل الترخيص',
  };
}