import 'package:my_ecommerce_app/screens/home_screen.dart'; //
import 'package:my_ecommerce_app/screens/login_screen.dart'; //
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:flutter/material.dart'; //
import 'package:flutter_native_splash/flutter_native_splash.dart';
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the stream and rebuilds on change [cite: 294, 312]
    return StreamBuilder<User?>(
      // The stream automatically emits User or null [cite: 296, 314]
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Once the connection is active (meaning the initial auth check is done)
        if (snapshot.connectionState == ConnectionState.active) {
          // Remove the splash screen after the auth check is complete
          FlutterNativeSplash.remove();
        }

        // 1. Show a loading spinner if we are waiting for the initial auth check [cite: 302, 316]
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If the snapshot has data, the user is logged in [cite: 307, 317]
        if (snapshot.hasData) {
          return const HomeScreen(); // Show the home screen [cite: 308]
        }

        // 3. If no data, the user is logged out (show Login) [cite: 309]
        return const LoginScreen(); // Show the login screen [cite: 310]
      },
    );
  }
}