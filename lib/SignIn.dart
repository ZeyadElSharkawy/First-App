import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Classes/Buttons.dart';
import 'Classes/Labels.dart';
import 'Classes/Language.dart';
import 'server/preferances.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isArabic = false;
  bool obscurePassword = true;
  bool isLoading = false;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // Error states
  String? emailError;
  String? passwordError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hint, {Widget? suffixIcon, String? errorText}) {
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
      suffixIcon: suffixIcon,
    );
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailError = isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required';
      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
        emailError = isArabic ? 'صيغة البريد غير صحيحة' : 'Invalid email format';
      } else {
        emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
      } else {
        passwordError = null;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
  // Validate fields
  _validateEmail(emailCtrl.text);
  _validatePassword(passwordCtrl.text);

  if (emailError != null || passwordError != null) {
    _showError(isArabic ? 'الرجاء إصلاح الأخطاء' : 'Please fix the errors');
    return;
  }

  setState(() => isLoading = true);

  try {
    // Attempt to sign in
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );

    // IMPORTANT: Save logged in state to SharedPreferences
    final prefs = PreferencesService();
    await prefs.setLoggedIn(true);

    if (mounted) {
      _showSuccess(isArabic ? 'تم تسجيل الدخول بنجاح' : 'Sign in successful!');
      
      // Navigate to home page
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } on FirebaseAuthException catch (e) {
    // Handle specific Firebase auth errors
    String errorMessage;
    
    if (e.code == 'user-not-found') {
      errorMessage = isArabic ? 'لا يوجد مستخدم بهذا البريد' : 'No user found with this email';
    } else if (e.code == 'wrong-password') {
      errorMessage = isArabic ? 'كلمة المرور غير صحيحة' : 'Wrong password';
    } else if (e.code == 'invalid-email') {
      errorMessage = isArabic ? 'البريد الإلكتروني غير صالح' : 'Invalid email address';
    } else if (e.code == 'user-disabled') {
      errorMessage = isArabic ? 'تم تعطيل هذا الحساب' : 'This account has been disabled';
    } else if (e.code == 'invalid-credential') {
      errorMessage = isArabic ? 'بيانات الدخول غير صحيحة' : 'Invalid credentials';
    } else if (e.code == 'too-many-requests') {
      errorMessage = isArabic ? 'محاولات كثيرة جداً. حاول لاحقاً' : 'Too many attempts. Try again later';
    } else {
      errorMessage = isArabic ? 'خطأ في تسجيل الدخول: ${e.message}' : 'Sign in error: ${e.message}';
    }
    
    if (mounted) {
      _showError(errorMessage);
    }
  } catch (e) {
    if (mounted) {
      _showError(isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred: $e');
    }
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تسجيل الدخول' : 'Sign In'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            LanguageSwitch(
              isArabic: isArabic,
              onChanged: (val) => setState(() => isArabic = val),
            ),
            const SizedBox(height: 60),
            // Profile Image / Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.person, size: 60, color: Colors.teal),
            ),
            const SizedBox(height: 40),
            StyledLabel(text: isArabic ? 'مرحبا بك' : 'Welcome', size: 28),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'تسجيل الدخول إلى حسابك' : 'Sign in to your account',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 40),
            // Email Field
            StyledLabel(text: isArabic ? 'البريد الإلكتروني' : 'Email'),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged: _validateEmail,
              decoration: _buildInputDecoration(
                isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                errorText: emailError,
              ),
            ),
            const SizedBox(height: 20),
            // Password Field
            StyledLabel(text: isArabic ? 'كلمة المرور' : 'Password'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordCtrl,
              obscureText: obscurePassword,
              onChanged: _validatePassword,
              decoration: _buildInputDecoration(
                isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
                errorText: passwordError,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  child: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // TODO: Implement forgot password
                  _showError(isArabic ? 'قريبا' : 'Coming soon');
                },
                child: Text(
                  isArabic ? 'هل نسيت كلمة المرور؟' : 'Forgot Password?',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Sign In Button
            isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  )
                : StyledButton(
                    label: isArabic ? 'تسجيل الدخول' : 'Sign In',
                    color: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                    onPressed: signInWithEmailAndPassword,
                  ),
            const SizedBox(height: 20),
            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? "),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/signup'),
                  child: Text(
                    isArabic ? 'انشئ حساب' : 'Sign Up',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}