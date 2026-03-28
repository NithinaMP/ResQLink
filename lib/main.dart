// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'screens/login_screen.dart';
// import 'screens/dashboard_screen.dart';
// import 'firebase_config.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Firebase initialization with your config
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: FirebaseConfig.apiKey,
//       authDomain: FirebaseConfig.authDomain,
//       projectId: FirebaseConfig.projectId,
//       storageBucket: FirebaseConfig.storageBucket,
//       messagingSenderId: FirebaseConfig.messagingSenderId,
//       appId: FirebaseConfig.appId,
//     ),
//   );
//
//   runApp(const ResQLinkApp());
// }
//
// class ResQLinkApp extends StatelessWidget {
//   const ResQLinkApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ResQLink',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.red,
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//       ),
//       // Auto-check if officer is already logged in
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           // Loading state
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               backgroundColor: Color(0xFF1a1a1a),
//               body: Center(
//                 child: CircularProgressIndicator(color: Colors.red),
//               ),
//             );
//           }
//           // Already logged in → Dashboard
//           if (snapshot.hasData) return const DashboardScreen();
//           // Not logged in → Login
//           return const LoginScreen();
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqlink/screens/dashboard_screen.dart';
import 'package:resqlink/screens/login_screen.dart';


import 'package:flutter/foundation.dart';           // add this if not present
import 'firebase_options.dart';                    // make sure this import exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ResQLinkApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase (Auto-config using google-services.json)
//   await Firebase.initializeApp();
//
//   runApp(const ResQLinkApp());
// }

class ResQLinkApp extends StatelessWidget {
  const ResQLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      // Auto-check login state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF1a1a1a),
              body: Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            );
          }

          // If logged in → Dashboard
          if (snapshot.hasData) {
            return const DashboardScreen();
          }

          // If not logged in → Login
          return const LoginScreen();
        },
      ),
    );
  }
}
