import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class ScanController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  void onClose() {
    // Dispose of the camera controller properly
    if (cameraController.value.isInitialized) {
      cameraController.stopImageStream();
      cameraController.dispose();
    }
    super.onClose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var result = ''.obs;
  var iceImage = Rxn<Uint8List>();

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            imageClassifier(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Permission Denied");
    }
  }

  Future<void> initTFLite() async {
    await Tflite.loadModel(
        model:
            "lib/assets/image_recognition_models/ice_counter_1/model_unquant.tflite",
        labels: "lib/assets/image_recognition_models/ice_counter_1/labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false);
  }

  imageClassifier(CameraImage image) async {
    var classifier = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e) {
          return e.bytes;
        }).toList(),
        asynch: true,
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 2,
        rotation: 90,
        threshold: 0.4);

    if (classifier != null) {
      result.value = classifier[0]['label'];
      if (result.value == 'ice') {
        iceImage.value = convertYUV420ToUint8List(image);
      }
    }
  }


  Uint8List convertYUV420ToUint8List(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final img.Image imgImage = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int pixelIndex = y * width + x;
        final int pixelValue = image.planes[0].bytes[pixelIndex];
        imgImage.setPixel(x, y, img.getColor(pixelValue, pixelValue, pixelValue));
      }
    }

    return Uint8List.fromList(img.encodeJpg(imgImage));
  }
}
