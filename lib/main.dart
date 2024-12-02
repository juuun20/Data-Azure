import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_connect/firebase_options.dart';
import 'package:pet_connect/home_screen.dart';
import 'package:pet_connect/pet_connect_screen.dart';
import 'package:pet_connect/login_screen.dart';
import 'package:pet_connect/pet_form.dart';
import 'package:pet_connect/services/owners_form.dart';
import 'package:pet_connect/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(     
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const PetConnectScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/ownersform': (context) => const PetOwnerProfileScreen(),
        '/petform': (context) => const PetFormScreen(),
      },
    );
  }
}
