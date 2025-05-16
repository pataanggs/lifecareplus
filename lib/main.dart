import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'providers/user_provider.dart';
import 'providers/medicine_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/gender_selection_screen.dart';
import 'dart:developer' as developer;

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase with proper error handling
    developer.log('Initializing Firebase...');
    await FirebaseService.initializeFirebase();
    developer.log('Firebase initialization successful');

    // Run the app with providers
    developer.log('Starting LifeCare+ app');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ],
        child: const LifeCareApp(),
      ),
    );
  } catch (e) {
    developer.log('Error during app initialization: $e', error: e);
    // Run a minimal app to avoid complete crash
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Error initializing app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Details: $e',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Restart app (just reloads current page)
                    main();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LifeCareApp extends StatelessWidget {
  const LifeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize medicine provider
    final medicineProvider = Provider.of<MedicineProvider>(
      context,
      listen: false,
    );
    medicineProvider.listenToMedicines();

    return MaterialApp(
      title: 'LifeCare+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
        primaryColor: Color(0xFF5C6BC0), // Indigo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const GenderSelectionScreen(),
      },
    );
  }
}
