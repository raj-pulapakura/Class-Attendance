import 'dart:math';
import 'dart:typed_data';

import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/student.dart';
import 'package:app/utils/image_converter.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as imgLib;

class FaceComparison {
  late tfl.Interpreter interpreter;

  Future<void> initializeInterperter() async {
    interpreter = await tfl.Interpreter.fromAsset(
      "mobilefacenet.tflite",
    );
  }

  Float32List convertImageToByteListFloat32(imgLib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        final redChannel = pixel.getChannel(imgLib.Channel.red);
        final blueChannel = pixel.getChannel(imgLib.Channel.blue);
        final greenChannel = pixel.getChannel(imgLib.Channel.green);
        buffer[pixelIndex++] = (redChannel - 128) / 128;
        buffer[pixelIndex++] = (blueChannel - 128) / 128;
        buffer[pixelIndex++] = (greenChannel - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  imgLib.Image cropFace(imgLib.Image image, Face faceDetected) {
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imgLib.copyCrop(
      image,
      x: x.round(),
      y: y.round(),
      width: w.round(),
      height: h.round(),
    );
  }

  Future<List> runInferenceForCameraImage(
    CameraImage cameraImage,
    Face face,
  ) async {
    print("Converting image");
    imgLib.Image? convertedImage = convertToImage(cameraImage);

    if (convertedImage == null) {
      throw Exception("Could not process because of invalid image format");
    }

    print("Cropping image to detected face");
    imgLib.Image croppedImage = cropFace(convertedImage, face);

    print("Resizing image");
    imgLib.Image resizedImage = imgLib.copyResizeCropSquare(
      croppedImage,
      size: 112,
    );

    print("Converting image to list for inference");
    List input = convertImageToByteListFloat32(resizedImage);

    print("Reshaping input into appropriate shape for inference");
    input = input.reshape([1, 112, 112, 3]);

    print("Creating empty output list");
    List output = List.generate(1, (index) => List.filled(192, 0));

    print("Initializing interpreter");
    await initializeInterperter();

    print("Running model");
    interpreter.run(input, output);

    print("Reshaping output");
    output = List.from(output.reshape([192]));

    return output;
  }

  Future<List> runInferenceForStudentImage(String imgUrl) async {
    return [];
  }

  num calculateEuclideanDistance(List l1, List l2) {
    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }

    return pow(sum, 0.5);
  }

  Future<Student> findMostSimilarIdentity({
    required CameraImage cameraImage,
    required Face face,
  }) async {
    // inference
    final cameraFeedEmbeddings =
        await runInferenceForCameraImage(cameraImage, face);

    // get all students
    final students = await FirebaseDataManager.getAllStudents();

    // initialize trackers
    Student matchedIdentity = students[0];
    num minDistance = 999;
    double threshold = 1.5;

    for (final student in students) {
      if (student.imgUrl == null) continue;

      // calculate embeddings for the student face
      final studentEmbeddings =
          await runInferenceForStudentImage(student.imgUrl!);

      // calculate the distance between the camera face embeddings and the student face embeddings
      final distance = calculateEuclideanDistance(
        cameraFeedEmbeddings,
        studentEmbeddings,
      );

      // if the distance is lower than the threshold and the current lowest distance, update the trackers
      if (distance < threshold && distance < minDistance) {
        matchedIdentity = student;
        minDistance = distance;
      }
    }

    return matchedIdentity;
  }
}
