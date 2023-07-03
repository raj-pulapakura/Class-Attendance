import 'dart:io';
import 'dart:typed_data';
import 'package:app/models/firebase_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final primaryContactController = TextEditingController();
  final secondaryContactController = TextEditingController();

  final picker = ImagePicker();
  String imageError = "";

  late FaceDetector faceDetector;
  List<Face> facesDetected = [];
  File? croppedFace;

  @override
  void initState() {
    faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    primaryContactController.dispose();
    secondaryContactController.dispose();
    super.dispose();
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

  Future<void> getImageFromImagePickerAndSaveDetectedFace() async {
    // get image from image picker
    final image = await getImageFromImagePicker();
    if (image == null) {
      return;
    }

    // use face detector to calculate bounding box of face
    final InputImage inputImage = InputImage.fromFile(image);
    final List<Face> result = await faceDetector.processImage(inputImage);
    final Rect boundingBox = result[0].boundingBox;

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

    // set the bounding boxes state and newly cropped face
    setState(() {
      facesDetected = result;
      croppedFace = croppedImageFile;
    });
  }

  String? validateTextField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid';
    }
    return null;
  }

  bool validateForm() {
    // validate text fields
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // validate image
    setState(() {
      imageError = "";
    });

    if (croppedFace == null) {
      setState(() {
        imageError = "Please select an image";
      });
      return false;
    }

    return true;
  }

  void showSnackBarBegin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adding student to database')),
    );
  }

  void showSnackBarFinished() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added ${firstNameController.text} ${lastNameController.text} to database'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> submitForm() async {
    if (!validateForm()) return;

    showSnackBarBegin();

    await FirebaseDataManager.addStudent(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      primaryContact: primaryContactController.text,
      secondaryContact: secondaryContactController.text,
      image: croppedFace!,
    );

    showSnackBarFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: "First Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: "Last Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: primaryContactController,
            decoration: const InputDecoration(labelText: "Primary contact"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: secondaryContactController,
            decoration: const InputDecoration(labelText: "Secondary contact"),
            validator: validateTextField,
          ),
          TextButton(
            onPressed: getImageFromImagePickerAndSaveDetectedFace,
            child: const Text("Choose image"),
          ),
          if (croppedFace != null)
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 300,
              color: Colors.grey[300],
              child: Image.file(croppedFace!),
            ),
          if (imageError != "") Text(imageError),
          ElevatedButton(
            onPressed: submitForm,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
