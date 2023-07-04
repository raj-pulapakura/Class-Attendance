import 'dart:io';
import 'dart:async';
import 'package:app/models/model_service.dart';
import 'package:app/models/student.dart';
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
  Student? matchedIdentity;
  ModelService modelService = ModelService();
  bool finishedOneInference = true;

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
        mode: FaceDetectorMode.fast,
      ),
    );
  }

  void initializeCamera(
    CameraDescription cameraDescription,
    bool shouldSetState,
  ) async {
    if (shouldSetState) {
      setState(() {
        cameraController =
            CameraController(cameraDescription, ResolutionPreset.low);
      });
    } else {
      cameraController =
          CameraController(cameraDescription, ResolutionPreset.low);
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
            .then((Student matchedStudent) {
          setState(() {
            matchedIdentity = matchedStudent;
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

  Future<void> scanFromFile() async {
    final XFile xFile = await cameraController.takePicture();
    Face? face = await detectFaceFromFileImage(File(xFile.path));

    if (face == null) {
      return;
    }

    await modelService.initializeInterperter();

    Student matchedStudent =
        await modelService.findMostSimilarIdentityFromFileImage(
      file: File(xFile.path),
      face: face,
    );

    setState(() {
      matchedIdentity = matchedStudent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !cameraController.value.isInitialized
          ? const Center(
              child: Text("Loading..."),
            )
          : Column(
              children: [
                CameraPreview(cameraController),
                if (matchedIdentity == null)
                  const Text("Detecting...")
                else
                  Text(
                      "Detected student: ${matchedIdentity!.firstName} ${matchedIdentity!.lastName}"),
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
          FloatingActionButton(
            onPressed: switchCameraPerspective,
            child: const Icon(Icons.cameraswitch),
          ),
        ],
      ),
    );
  }
}
