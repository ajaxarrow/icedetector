import 'package:flutter/material.dart';
import 'package:icedetector/screens/detector_screen.dart';
import 'package:icedetector/screens/landing_screen.dart';
import 'package:icedetector/screens/reports_screen.dart';
import 'package:icedetector/themes/theme.dart';
import 'package:icedetector/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/main': (context) => const DetectorScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
