import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  detectIce(Uint8List image) async {
    final timeStart = DateTime.now().millisecondsSinceEpoch;
    await uploadImage(image, timeStart.toString());
    _firebaseLogsRef.push().set({
      "timestamp_start": timeStart,
      "timestamp_end": DateTime.now().millisecondsSinceEpoch,
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 2),
      content: Text("Ice Detected!"),
    ));
  }

  Future<void> uploadImage(Uint8List image, String imageName) async {
    if (image != null) {
      try {
        final String fileName = 'images/$imageName.jpg';
        final UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putData(image);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ScanController().onCameraClose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 1280;

    if (isLargeScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Column(
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
                        height: MediaQuery.of(context).size.height * .80,
                        width: MediaQuery.of(context).size.width * .25,
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
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GetBuilder<ScanController>(
                    builder: (controller) {
                      if(controller.isCameraInitialized.value){
                        final cameras = controller.cameras;
                        return Row(
                          children: [
                            const Text('Selected Camera: '),
                            DropdownButton<int>(
                              value: controller.selectedCamera.value,
                              items: cameras
                                  .asMap()
                                  .entries
                                  .map<DropdownMenuItem<int>>(
                                    (entry) => DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Text('Camera ${entry.key + 1}'),
                                ),
                              )
                                  .toList(),
                              onChanged: (index) {
                                controller.selectCamera(index!);
                              },
                            )
                          ],
                        );
                      } else {
                        return const Text('Loading camera...');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                GetBuilder<ScanController>(
                  builder: (controller) {
                    final result = controller.result.value;
                    final image = controller.iceImage.value;
                    if (result == "ice" && hasDetectedIce == false) {
                      detectIce(image!);
                      hasDetectedIce = true;
                    } else if (result == "no ice" && hasDetectedIce == true) {
                      hasDetectedIce = false;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: result == "ice" ? successColor : warningColor,
                        ),
                        child: Center(
                          child: Text(
                            result == "ice" ? 'Ice Detected' : 'No Ice Detected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                const Expanded(child: SummarySnippet()),
              ],
            ),
          ),
        ],
      );
    } else {
      // For smaller screens, use a single-column layout
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
                  height: isSmallScreen ? MediaQuery.of(context).size.height * .40 : MediaQuery.of(context).size.height * .60,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GetBuilder<ScanController>(
              builder: (controller) {
                if(controller.isCameraInitialized.value){
                  final cameras = controller.cameras;
                  return Row(
                    children: [
                      const Text('Selected Camera: '),
                      DropdownButton<int>(
                        value: controller.selectedCamera.value,
                        items: cameras
                            .asMap()
                            .entries
                            .map<DropdownMenuItem<int>>(
                              (entry) => DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text('Camera ${entry.key + 1}'),
                          ),
                        )
                            .toList(),
                        onChanged: (index) {
                          controller.selectCamera(index!);
                        },
                      )
                    ],
                  );
                } else {
                  return const Text('Loading camera...');
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          GetBuilder<ScanController>(
            builder: (controller) {
              final result = controller.result.value;
              final image = controller.iceImage.value;
              if (result == "ice" && hasDetectedIce == false) {
                detectIce(image!);
                hasDetectedIce = true;
              } else if (result == "no ice" && hasDetectedIce == true) {
                hasDetectedIce = false;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: result == "ice" ? successColor : warningColor,
                  ),
                  child: Center(
                    child: Text(
                      result == "ice" ? 'Ice Detected' : 'No Ice Detected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          const Expanded(child: SummarySnippet()),
        ],
      );
    }
  }
}
