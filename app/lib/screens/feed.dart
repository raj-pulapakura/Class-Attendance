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
  late CameraController controller;
  late FaceDetector faceDetector;
  List<Face> facesDetected = [];

  void initializeCamera() {
    controller.initialize().then(
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
    controller = CameraController(widget.cameras[1], ResolutionPreset.max);
    initializeCamera();
    faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onSwitchCameraButtonPressed() {
      if (controller.description == widget.cameras[0]) {
        controller.setDescription(widget.cameras[1]);
      } else {
        controller.setDescription(widget.cameras[0]);
      }
    }

    return Scaffold(
      body: !controller.value.isInitialized
          ? const Center(
              child: Text("Loading..."),
            )
          : CameraPreview(controller),
      floatingActionButton: Wrap(
        direction: Axis.horizontal,
        children: [
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
