import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Inisialisasi Firebase Kedua (sunvolt-admin)
  await Firebase.initializeApp(
    name: 'secondary',
    options: const FirebaseOptions(
      apiKey: "AIzaSyApn4txSJN29ZRle9hOqMli0zfkya8Uh-Q",
      authDomain: "sunvolt-admin.firebaseapp.com",
      projectId: "sunvolt-admin",
      storageBucket: "sunvolt-admin.firebasestorage.app",
      messagingSenderId: "759944928251",
      appId: "1:759944928251:web:602607c4d46d04bf86c95e",
      measurementId: "G-Y6X03PP9EV",
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SunVoltApp());
}

class SunVoltApp extends StatelessWidget {
  const SunVoltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunVolt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
