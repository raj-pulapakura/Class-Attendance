import 'dart:io';

import 'package:app/models/face_comparison.dart';
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
  File? file;
  Student? matchedIdentity;
  bool loadingStudentIdentity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );

    cameraController =
        CameraController(widget.cameras[1], ResolutionPreset.low);

    initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.stopImageStream();
    cameraController.dispose();
    super.dispose();
  }

  void initializeCamera() {
    cameraController.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
    ).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case "CameraAccessDenied":
            break;
          default:
            break;
        }
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
    InputImageData firebaseImageMetadata = InputImageData(
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

    InputImage firebaseVisionImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: firebaseImageMetadata,
    );
    final List<Face> faces =
        await faceDetector.processImage(firebaseVisionImage);

    if (faces.isEmpty) return null;
    return faces[0];
  }

  Future<Face?> detectFaceFromFileImage(File file) async {
    final inputImage = InputImage.fromFile(file);

    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;
    return faces[0];
  }

  onIdentityButtonPressed() async {
    setState(() {
      loadingStudentIdentity = true;
    });

    final XFile xFile = await cameraController.takePicture();
    setState(
      () {
        file = File(xFile.path);
      },
    );

    Face? face = await detectFaceFromFileImage(File(xFile.path));

    if (face == null) {
      setState(() {
        loadingStudentIdentity = false;
      });
      return;
    }

    Student matchedStudent =
        await FaceComparison().findMostSimilarIdentityFromFileImage(
      file: File(xFile.path),
      face: face,
    );

    setState(() {
      matchedIdentity = matchedStudent;
      loadingStudentIdentity = false;
    });
  }

  void onSwitchCameraButtonPressed() {
    setState(
      () {
        cameraController = CameraController(
            widget.cameras[
                cameraController.description == widget.cameras[0] ? 1 : 0],
            ResolutionPreset.low);
      },
    );
    initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !cameraController.value.isInitialized
          ? const Center(
              child: Text("Loading..."),
            )
          : CameraPreview(cameraController),
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: FloatingActionButton(
              onPressed: onIdentityButtonPressed,
              child: const Icon(
                Icons.perm_identity,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: FloatingActionButton(
              onPressed: onSwitchCameraButtonPressed,
              child: const Icon(
                Icons.switch_camera,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.home,
            ),
          ),
          if (matchedIdentity != null)
            Text(
                "Student found: ${matchedIdentity!.firstName} ${matchedIdentity!.lastName}"),
          if (loadingStudentIdentity) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
