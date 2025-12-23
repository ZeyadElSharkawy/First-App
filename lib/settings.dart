import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_state.dart';
import 'server/preferances.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final prefs = PreferencesService();

  bool isDark = false;
  String language = 'en';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isDark = await prefs.getTheme();
    language = await prefs.getLanguage();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = language == 'ar';

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppState.themeNotifier,
      builder: (context, themeMode, _) {
        final isDarkMode = themeMode == ThemeMode.dark;
        
        // Define colors based on theme
        final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.grey[50]!;
        final cardColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final subtleTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
        final primaryColor = isDarkMode ? Colors.teal[700]! : Colors.teal;
        final shadowColor = isDarkMode 
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.grey.withValues(alpha: 0.1);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isArabic ? 'الإعدادات' : 'Settings',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dark Mode Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SwitchListTile(
                            value: isDark,
                            title: Text(
                              isArabic ? 'الوضع الداكن' : 'Dark Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            activeThumbColor: primaryColor,
                            onChanged: (value) async {
                              setState(() => isDark = value);
                              await prefs.setTheme(value);
                              AppState.themeNotifier.value =
                                  value ? ThemeMode.dark : ThemeMode.light;
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Language Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: shadowColor,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isArabic ? 'اللغة' : 'Language',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? const Color(0xFF3C3C3C)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isDarkMode 
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: language,
                                      isDense: true,
                                      dropdownColor: isDarkMode 
                                          ? const Color(0xFF3C3C3C)
                                          : Colors.white,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'en',
                                          child: Text(
                                            'English',
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ar',
                                          child: Text(
                                            'العربية',
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) async {
                                        if (value == null) return;
                                        setState(() => language = value);
                                        await prefs.setLanguage(value);
                                        AppState.localeNotifier.value = Locale(value);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Profile Button
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'صفحة الملف الشخصي قريباً'
                                      : 'Profile page coming soon',
                                ),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      isArabic ? 'الملف الشخصي' : 'Profile',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              // Show confirmation dialog
                              final shouldSignOut = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  backgroundColor: cardColor,
                                  title: Text(
                                    isArabic ? 'تسجيل الخروج' : 'Sign Out',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: Text(
                                    isArabic
                                        ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                                        : 'Are you sure you want to sign out?',
                                    style: TextStyle(color: subtleTextColor),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext, false),
                                      child: Text(
                                        isArabic ? 'إلغاء' : 'Cancel',
                                        style: TextStyle(color: primaryColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext, true),
                                      child: Text(
                                        isArabic ? 'تسجيل الخروج' : 'Sign Out',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldSignOut == true) {
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  await prefs.setLoggedIn(false);

                                  if (mounted) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/signin',
                                      (route) => false,
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isArabic
                                              ? 'خطأ في تسجيل الخروج'
                                              : 'Error signing out',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text(
                              isArabic ? 'تسجيل الخروج' : 'Sign Out',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}