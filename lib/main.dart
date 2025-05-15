import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const LifeCareApp(),
    ),
  );
}

class LifeCareApp extends StatelessWidget {
  const LifeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeCare+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial', useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
