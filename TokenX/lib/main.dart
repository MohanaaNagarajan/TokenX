import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase if configuration is present
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // If Firebase configuration is not attached yet, the app falls back
    // cleanly to the local reactive mock service for instant viva demonstration.
    debugPrint('Firebase not configured. Running in Demo / Offline Mode.');
  }

  // System UI Overlay configuration (Status bar styling)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TokenXApp());
}

class TokenXApp extends StatelessWidget {
  const TokenXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
