import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings.dart' as app_settings;
import 'app_state.dart';
import 'Classes/Strings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  String? profilePhotoUrl;
  String userName = 'User';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firebase
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          setState(() {
            userName = data?['fullName'] ?? 'User';
            
            // Get profile photo URL from files.profilePhotoUrl (new structure)
            // or fallback to old structure for backward compatibility
            if (data?['files'] != null && data!['files']['profilePhotoUrl'] != null) {
              profilePhotoUrl = data['files']['profilePhotoUrl'];
            } else {
              profilePhotoUrl = data?['profilePhotoUrl'];
            }
            
            isLoading = false;
          });
          
          print('User loaded: $userName');
          print('Profile photo URL: $profilePhotoUrl');
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const app_settings.Settings()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppState.localeNotifier,
      builder: (context, locale, _) {
        final isArabic = locale.languageCode == 'ar';
        final translations = isArabic ? AppLocale.AR : AppLocale.EN;
        
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppState.themeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;
            
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
              body: _buildHomePage(translations, isArabic, isDark),
            );
          },
        );
      },
    );
  }

Widget _buildHomePage(Map<String, dynamic> translations, bool isArabic, bool isDark) {
  final primaryColor = isDark ? Colors.teal[700]! : Colors.teal;
  final textColor = isDark ? Colors.white : Colors.black87;
  final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
  
  return Stack(
    children: [
      // Background curved design
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 250),
          painter: CurvedBackgroundPainter(color: primaryColor),
        ),
      ),
      
      SafeArea(
        child: Column(
          children: [
            // Header with umbrella icon
            SizedBox(
              height: 120, // Fixed height for header area
              child: Stack(
                children: [
                  // Home title on left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        translations[AppLocale.home],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Profile on right
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(translations[AppLocale.profileTapped]),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                      )
                                    : profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                                        ? Image.network(
                                            profilePhotoUrl!,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading profile photo: $error');
                                              return Icon(
                                                Icons.person,
                                                color: primaryColor,
                                                size: 30,
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            color: primaryColor,
                                            size: 30,
                                          ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName.split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Umbrella icon in the center (between Home and Profile)
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'lib/umbrella.png', // Your umbrella/weather icon
                      width: 80, // Adjust size as needed
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            // Cards Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildCard(
                      translations[AppLocale.dashboard],
                      Icons.speed,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage(translations[AppLocale.dashboard], translations),
                    ),
                    _buildCard(
                      translations[AppLocale.clinicalRisks],
                      Icons.shield,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage('Clinical & Non-clinical Risks', translations),
                    ),
                    _buildCard(
                      translations[AppLocale.ovr],
                      Icons.location_pin,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage(translations[AppLocale.ovr], translations),
                    ),
                    _buildCard(
                      translations[AppLocale.staffRisk],
                      Icons.people,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage(translations[AppLocale.staffRisk], translations),
                    ),
                    _buildCard(
                      translations[AppLocale.pcraIcra],
                      Icons.construction,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage(translations[AppLocale.pcraIcra], translations),
                    ),
                    _buildCard(
                      translations[AppLocale.kpis],
                      Icons.bar_chart,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDark,
                      () => _navigateToPage(translations[AppLocale.kpis], translations),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: translations[AppLocale.home],
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onNavItemTapped(0),
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    label: translations[AppLocale.settings],
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onNavItemTapped(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildCard(
    String title,
    IconData icon,
    Color color,
    Color cardColor,
    Color textColor,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(String pageName, Map<String, dynamic> translations) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${translations[AppLocale.navigatingTo]} $pageName...')),
    );
  }
}

// Custom painter for the curved background
class CurvedBackgroundPainter extends CustomPainter {
  final Color color;
  
  CurvedBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    path.moveTo(0, 0); 
    // This creates a steep curve that starts and peaks on the left side
    path.lineTo(0, size.height * 0.9); 
    path.quadraticBezierTo(
      size.width * 0.05, // Peak is at 5% width (Top Left)
      size.height * 0.5, 
      size.width,        // Ends at the right edge
      0,                 // Back to the top
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}