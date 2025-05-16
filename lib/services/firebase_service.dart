import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        developer.log('Firebase already initialized, reusing existing app');
        return;
      }

      // Default options for different platforms
      FirebaseOptions? options;

      if (Platform.isAndroid) {
        options = const FirebaseOptions(
          apiKey: 'AIzaSyBKFR2-2hGt23_htRcb4zwI5mAr3FAXs5Q',
          appId: '1:338603757091:android:8343b2a3b04fb48ad16b96',
          messagingSenderId: '338603757091',
          projectId: 'lifecareplus-e76e9',
          storageBucket: 'lifecareplus-e76e9.appspot.com',
          authDomain: 'lifecareplus-e76e9.firebaseapp.com',
        );
      }

      // Use options if available, otherwise default
      await Firebase.initializeApp(options: options);

      developer.log('Firebase initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize Firebase: $e');
      throw Exception('Failed to initialize Firebase: $e');
    }
  }
}
