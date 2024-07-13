import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icedetector/controllers/scan_controller.dart';
import 'package:icedetector/themes/colors.dart';
import 'package:icedetector/widgets/summary_snippet.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen> {
  final _firebaseLogsRef = FirebaseDatabase.instance.ref('logs');
  bool hasDetectedIce = false;

  detectIce() async {
    _firebaseLogsRef.push().set({
      "timestamp_start": DateTime.now().millisecondsSinceEpoch,
      "timestamp_end": DateTime.now().millisecondsSinceEpoch
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 2),
      content: Text("Ice Detected!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              border: Border.all(color: primaryColor, width: 2.0),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .40,
                width: MediaQuery.of(context).size.width * .50,
                child: GetBuilder<ScanController>(
                  init: ScanController(),
                  builder: (controller) {
                    return controller.isCameraInitialized.value
                        ? CameraPreview(controller.cameraController)
                        : const Center(
                            child: Text('Loading Preview...'),
                          );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Adjust the radius as needed
              ),
            ),
            onPressed: detectIce,
            child: const Text('Detect Ice'),
          ),
        ),
        const SizedBox(height: 15),
        const Expanded(child: SummarySnippet()),
        GetBuilder<ScanController>(
          builder: (controller) {
            if (controller.result.value == "ice" && hasDetectedIce == false) {
              detectIce();
              hasDetectedIce = true;
            } else if (controller.result.value == "no ice" &&
                hasDetectedIce == true) {
              hasDetectedIce = false;
            }
            return Text(
              controller.result.value,
              style: const TextStyle(fontSize: 20),
            );
          },
        ),
      ],
    );
  }
}
