import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'providers/medicine_provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';

import 'screens/onboarding/gender_selection_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/root_screen.dart';

// Create a route observer to track navigation
class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    developer.log(
      'Route PUSHED: ${route.settings.name} (from: ${previousRoute?.settings.name})',
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    developer.log(
      'Route REPLACED: ${newRoute?.settings.name} (old: ${oldRoute?.settings.name})',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    developer.log(
      'Route POPPED: ${route.settings.name} (to: ${previousRoute?.settings.name})',
    );
    super.didPop(route, previousRoute);
  }
}

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    developer.log('Initializing Firebase');
    await Firebase.initializeApp();

    // Initialize auth service
    developer.log('Initializing auth service');
    final authService = AuthService();
    final currentUser = authService.currentUser;
    developer.log('Current user at startup: ${currentUser?.uid ?? 'none'}');

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
    developer.log('Error during app initialization: $e');
    rethrow;
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
      title: 'LifeCare+ (Mock)',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [RouteObserver()],
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
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const RootScreen(),
        '/onboarding': (context) => const GenderSelectionScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
