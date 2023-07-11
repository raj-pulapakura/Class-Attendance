import 'dart:io';
import 'dart:async';
import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/model_service.dart';
import 'package:app/old_widgets/student_list_item.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with WidgetsBindingObserver {
  late CameraController cameraController;
  late FaceDetector faceDetector;
  ModelService modelService = ModelService();
  bool finishedOneInference = true;
  final ResolutionPreset resolution = ResolutionPreset.low;

  @override
  void initState() {
    super.initState();
    initializeFaceDetector();
    initializeCamera(widget.cameras[1], false);
    modelService.initializeInterperter();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.stopImageStream();
    cameraController.dispose();
  }

  void initializeFaceDetector() {
    faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  void initializeCamera(
    CameraDescription cameraDescription,
    bool shouldSetState,
  ) async {
    if (shouldSetState) {
      setState(() {
        cameraController = CameraController(cameraDescription, resolution);
      });
    } else {
      cameraController = CameraController(cameraDescription, resolution);
    }
    try {
      await cameraController.initialize();
      setState(() {});
      startPeriodicScanning();
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case "CameraAccessDenied":
            break;
          default:
            break;
        }
      }
    }
  }

  void startPeriodicScanning() {
    cameraController.startImageStream((CameraImage image) async {
      if (!finishedOneInference) return;
      setState(() {
        finishedOneInference = false;
      });
      final Face? face = await detectFaceFromCameraImage(image);
      if (face == null) {
        return setState(() {
          finishedOneInference = true;
        });
      }
      if (modelService.interpreterisReady) {
        modelService
            .findMostSimilarIdentity(cameraImage: image, face: face)
            .then((_) {
          setState(() {
            finishedOneInference = true;
          });
        });
      }
    });
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Future<Face?> detectFaceFromCameraImage(CameraImage image) async {
    InputImageData inputImageData = InputImageData(
      imageRotation: rotationIntToImageRotation(
          cameraController.description.sensorOrientation),
      inputImageFormat: InputImageFormat.BGRA8888,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    InputImage inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: inputImageData,
    );
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;
    return faces[0];
  }

  Future<Face?> detectFaceFromFileImage(File file) async {
    final inputImage = InputImage.fromFile(file);

    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;
    return faces[0];
  }

  void switchCameraPerspective() {
    print("init camera");
    initializeCamera(
      cameraController.description == widget.cameras[0]
          ? widget.cameras[1]
          : widget.cameras[0],
      true,
    );
  }

  Future<void> markStudentAsPresent() async {
    final studentIsPresent = await FirebaseDataManager.isMarkedAsPresent(
        modelService.globalMinStudent!.studentID!);

    if (studentIsPresent) {
      // tell the user the student is already present
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${modelService.globalMinStudent!.firstName} ${modelService.globalMinStudent!.lastName} is already present",
            ),
          ),
        );
      }
    } else {
      // mark the student as present
      await FirebaseDataManager.markStudentAsPresent(
          modelService.globalMinStudent!.studentID!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${modelService.globalMinStudent!.firstName} ${modelService.globalMinStudent!.lastName} has been marked as present",
            ),
          ),
        );
      }
    }
  }

  Widget buildStudentNotFoundWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Detecting..."),
      ],
    );
  }

  Widget buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.blue),
          shape: BoxShape.circle),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: IconButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.blue),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        padding: const EdgeInsets.all(20),
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  Widget buildStudentFoundWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: StudentListItem(
            student: modelService.globalMinStudent!,
            viewStudentOnClick: false,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildIconButton(
              icon: const Icon(Icons.check),
              onPressed: markStudentAsPresent,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !cameraController.value.isInitialized
          ? const Center(
              child: Text("Loading..."),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CameraPreview(cameraController),
                Expanded(
                  child: modelService.globalMinStudent == null
                      ? buildStudentNotFoundWidget()
                      : buildStudentFoundWidget(),
                ),
              ],
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.home),
          ),
          // FloatingActionButton(
          //   onPressed: switchCameraPerspective,
          //   child: const Icon(Icons.cameraswitch),
          // ),
        ],
      ),
    );
  }
}
