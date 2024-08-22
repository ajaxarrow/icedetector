import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ReadController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    cameraController.stopImageStream(); // Ensure image stream is stopped
    cameraController.dispose();
    super.dispose();
    cameraController.dispose();
  }

  void onCameraClose() {
    // Dispose of the camera controller properly
    if (cameraController.value.isInitialized) {
      cameraController.stopImageStream();
      cameraController.dispose();
    }
    super.onClose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var selectedCamera = 0.obs;
  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      print(cameras);
      cameraController =
          CameraController(cameras[selectedCamera.value], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
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

  void selectCamera(int index) {
    selectedCamera.value = index;
    cameraController.dispose(); // Dispose the current controller
    cameraController =
        CameraController(cameras[selectedCamera.value], ResolutionPreset.max);
    initCamera(); // Reinitialize with the newly selected camera
  }
}
