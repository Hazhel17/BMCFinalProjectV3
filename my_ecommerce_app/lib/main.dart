import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:my_ecommerce_app/screens/auth_wrapper.dart';
import 'package:provider/provider.dart'; // ADDED
import 'package:my_ecommerce_app/providers/cart_provider.dart'; // ADDED

void main() async {
  // 1. Ensure Flutter is ready and preserve the binding (Corrected the name)
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Preserve the splash screen until we manually remove it
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Run the application, wrapped in the ChangeNotifierProvider [cite: 109]
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // Creates the single cart instance [cite: 111-112]
      child: const MyApp(),
    ),
  );

  // 5. Remove the splash screen after the app is ready
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manga & Comics App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        primarySwatch: Colors.green,
        primaryColor: Colors.green,
        useMaterial3: true,
      ),
      // Set the AuthWrapper as the home screen
      home: const AuthWrapper(),
    );
  }
}