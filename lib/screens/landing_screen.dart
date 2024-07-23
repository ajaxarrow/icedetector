import 'package:flutter/material.dart';
import 'package:icedetector/themes/colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 100,),
          Image.asset(
            'lib/assets/images/ice-landing.png',
            width: MediaQuery.of(context).size.width < 500 ? 300 : 250,
            height: MediaQuery.of(context).size.width < 500 ? null : 250,
          ),
          const SizedBox(height: 15),
          const Text(
            'IceCount AI',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Revolutionize your ice inventory management with IceCount AI. Effortlessly count and track your ice blocks in real-time, ensuring accurate and efficient inventory control for your ice company.",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 30,
              ),
              backgroundColor: primaryColor,
            ),
            onPressed: (){
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSmall = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      body: Container(
        color: bgColor,
        height: double.infinity,
        width: double.infinity,
        child: isSmall
            ? buildContent()
            : Center(
          child: SizedBox(
            width: 500,
            child: buildContent(),
          ),
        ),
      ),
    );
  }
}
