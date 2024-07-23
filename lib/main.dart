import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icedetector/screens/auth_screen.dart';
import 'package:icedetector/screens/detector_screen.dart';
import 'package:icedetector/screens/landing_screen.dart';
import 'package:icedetector/screens/main_screen.dart';
import 'package:icedetector/screens/redirect_screen.dart';
import 'package:icedetector/screens/reports_screen.dart';
import 'package:icedetector/themes/theme.dart';
import 'package:icedetector/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/redirect',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/redirect': (context) => const RedirectScreen(),
        '/landing': (context) => const LandingScreen(),
        '/main:': (context) => const MainScreen(),
        '/live:': (context) => const DetectorScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
