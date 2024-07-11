import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController{

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var result= ''.obs;

  initCamera() async {
    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.max
      );
      await cameraController.initialize().then((value){
        cameraController.startImageStream((image){
          cameraCount++;
          if(cameraCount %10 == 0){
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
        model: "lib/assets/icecount.tflite",
        labels: "lib/assets/labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false
    );
  }

  imageClassifier(CameraImage image) async{
    var classifier = await Tflite.runModelOnFrame(bytesList: image.planes.map((e){
      return e.bytes;
    }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2,
      rotation: 90,
      threshold: 0.4
    );

    if(classifier != null){
      print(classifier);
      result.value = classifier[0]['label'];
    }
  }

}