import 'dart:io';
import 'dart:typed_data';

import 'package:app/models/firebase_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import "package:image/image.dart" as img;

class EditStudentImageButton extends StatefulWidget {
  const EditStudentImageButton({
    super.key,
    required this.studentID,
    required this.onClose,
  });

  final String studentID;
  final VoidCallback onClose;

  @override
  State<EditStudentImageButton> createState() => _EditStudentImageButtonState();
}

class _EditStudentImageButtonState extends State<EditStudentImageButton> {
  final picker = ImagePicker();
  String imageError = "";

  late FaceDetector faceDetector;

  @override
  void initState() {
    faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    super.initState();
  }

  Future<File?> getImageFromImagePicker() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      return null;
    }
    final image = File(pickedImage.path);
    return image;
  }

  Future<File?> getImageFromImagePickerAndCropDetectedFace() async {
    // get image from image picker
    final image = await getImageFromImagePicker();
    if (image == null) {
      return null;
    }

    showSnackBarBegin();

    // use face detector to calculate bounding box of face
    final InputImage inputImage = InputImage.fromFile(image);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    // get the largest bounding box by area
    faces.sort((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;

      if (areaA < areaB) {
        return 1;
      } else if (areaA == areaB) {
        return 0;
      } else {
        return -1;
      }
    });

    final Rect boundingBox = faces[0].boundingBox;

    // extract original image bytes
    final Uint8List bytes = await image.readAsBytes();

    // crop original image to bounding box
    final img.Image originalImage = img.decodeImage(bytes)!;
    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: boundingBox.left.toInt(),
      y: boundingBox.top.toInt(),
      width: boundingBox.width.toInt(),
      height: boundingBox.height.toInt(),
    );

    // convert cropped image into a file
    final File croppedImageFile = File('${image.path}_cropped.jpg');
    await croppedImageFile.writeAsBytes(img.encodeJpg(croppedImage));

    return croppedImageFile;
  }

  void showSnackBarBegin() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updating image")),
      );
    }
  }

  void showSnackBarFinished() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finished updating student image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: () async {
        final imageFile = await getImageFromImagePickerAndCropDetectedFace();
        if (imageFile == null) return;
        await FirebaseDataManager.updateStudentImage(
            widget.studentID, imageFile);
        widget.onClose();
        showSnackBarFinished();
      },
      icon: const Icon(Icons.edit),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.orange[500]),
      ),
    );
  }
}
