import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'core/theme.dart';
import 'features/home/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please set up Firebase. See FIREBASE_SETUP.md for instructions.');
    // Continue without Firebase - app will show error when trying to use Firebase services
  }
  
  runApp(MyApp(firebaseInitialized: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  
  const MyApp({super.key, this.firebaseInitialized = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        title: 'ROOMI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: firebaseInitialized 
            ? const SplashScreen()
            : const FirebaseSetupScreen(),
      ),
    );
  }
}

// Temporary screen to show Firebase setup instructions
class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup Required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Firebase Not Configured',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please set up Firebase to use this app.\n\n'
              '1. Create a Firebase project\n'
              '2. Add Android app with package: com.example.roomi_real_final\n'
              '3. Download google-services.json\n'
              '4. Place it in android/app/\n'
              '5. Restart the app\n\n'
              'See FIREBASE_SETUP.md for detailed instructions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Allow user to continue anyway (will crash on Firebase operations)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
              child: const Text('Continue Anyway (For Testing)'),
            ),
          ],
        ),
      ),
    );
  }
}
