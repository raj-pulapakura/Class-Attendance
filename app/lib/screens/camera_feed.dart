import 'package:app/models/face_comparison.dart';
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

class _FeedPageState extends State<FeedPage> {
  late CameraController cameraController;
  late FaceDetector faceDetector;

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

  @override
  void initState() {
    super.initState();
    cameraController =
        CameraController(widget.cameras[1], ResolutionPreset.max);
    initializeCamera();
    faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.fast,
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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

  Future<Face> detectFaceFromImage(CameraImage image) async {
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
    return faces[0];
  }

  @override
  Widget build(BuildContext context) {
    void onSwitchCameraButtonPressed() {
      setState(
        () {
          cameraController = CameraController(
              widget.cameras[
                  cameraController.description == widget.cameras[0] ? 1 : 0],
              ResolutionPreset.max);
        },
      );
    }

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
              onPressed: () {
                cameraController.startImageStream((CameraImage image) async {
                  final String matchedIdentity =
                      await FaceComparison().findMostSimilarIdentity(
                    cameraImage: image,
                    face: await detectFaceFromImage(image),
                  );
                  print(matchedIdentity);
                });
              },
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
        ],
      ),
    );
  }
}
