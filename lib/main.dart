import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'SignIn.dart';
import 'SignUp.dart';
import 'Home.dart';
import 'settings.dart';

import 'server/preferances.dart';
import 'server/supabase_service.dart'; // Import Supabase service
import 'app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // App can still work without Supabase, but file uploads will fail
  }

  // Load user preferences
  final prefs = PreferencesService();
  final isDark = await prefs.getTheme();
  final lang = await prefs.getLanguage();
  final loggedIn = await prefs.isLoggedIn();

  AppState.themeNotifier.value =
      isDark ? ThemeMode.dark : ThemeMode.light;
  AppState.localeNotifier.value = Locale(lang);

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.themeNotifier,
      builder: (_, ThemeMode mode, __) {
        return ValueListenableBuilder(
          valueListenable: AppState.localeNotifier,
          builder: (_, Locale locale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Clinic App',
              theme: ThemeData(
                primarySwatch: Colors.teal,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.teal,
                brightness: Brightness.dark,
              ),
              themeMode: mode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: isLoggedIn ? '/home' : '/signin',
              routes: {
                '/signin': (_) => const SignIn(),
                '/signup': (_) => const SignUp(),
                '/home': (_) => const Home(),
                '/settings': (_) => const Settings(),
              },
            );
          },
        );
      },
    );
  }
}