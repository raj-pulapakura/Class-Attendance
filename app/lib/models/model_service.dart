import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/student.dart';
import 'package:app/utils/image_converter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
import 'package:http/http.dart' show get;

class ModelService {
  late Interpreter interpreter;
  final inputSize = 112;
  final outputSize = 192;
  bool interpreterisReady = false;

  Future<void> initializeInterperter() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: true,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.minLatency,
          inferencePriority2: TfLiteGpuInferencePriority.auto,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);

      interpreterisReady = true;
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Float32List convertImageToByteListFloat32(img_lib.Image image) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        final redChannel = pixel.getChannel(img_lib.Channel.red);
        final blueChannel = pixel.getChannel(img_lib.Channel.blue);
        final greenChannel = pixel.getChannel(img_lib.Channel.green);
        buffer[pixelIndex++] = (redChannel - 128) / 128;
        buffer[pixelIndex++] = (blueChannel - 128) / 128;
        buffer[pixelIndex++] = (greenChannel - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  num calculateEuclideanDistance(List l1, List l2) {
    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }

    return pow(sum, 0.5);
  }

  img_lib.Image cropFace(img_lib.Image image, Face faceDetected) {
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return img_lib.copyCrop(
      image,
      x: x.round(),
      y: y.round(),
      width: w.round(),
      height: h.round(),
    );
  }

  Future<img_lib.Image> processImageFromCamera(
    CameraImage cameraImage,
    Face face,
  ) async {
    img_lib.Image? convertedImage = convertToImage(cameraImage);

    if (convertedImage == null) {
      throw Exception("Could not process because of invalid image format");
    }

    img_lib.Image croppedImage = cropFace(convertedImage, face);

    img_lib.Image resizedImage = img_lib.copyResizeCropSquare(
      croppedImage,
      size: inputSize,
    );

    return resizedImage;
  }

  img_lib.Image processImageFromFile(File file, Face face) {
    final img_lib.Image image = img_lib.Image.fromBytes(
      width: inputSize,
      height: inputSize,
      bytes: file.readAsBytesSync().buffer,
    );

    img_lib.Image croppedImage = cropFace(image, face);

    img_lib.Image resizedImage = img_lib.copyResizeCropSquare(
      croppedImage,
      size: inputSize,
    );

    return resizedImage;
  }

  Future<img_lib.Image> processImageFromUrl(String imgUrl) async {
    final response = await get(Uri.parse(imgUrl));
    final decodedImage = await decodeImageFromList(response.bodyBytes);

    final img_lib.Image image = img_lib.Image.fromBytes(
      width: decodedImage.width,
      height: decodedImage.height,
      bytes: (await decodedImage.toByteData())!.buffer,
    );

    img_lib.Image resizedImage = img_lib.copyResizeCropSquare(
      image,
      size: inputSize,
    );

    return resizedImage;
  }

  Future<List> runModel(img_lib.Image image) async {
    List input = convertImageToByteListFloat32(image);

    input = input.reshape([1, inputSize, inputSize, 3]);

    List output = List.generate(1, (index) => List.filled(outputSize, 0));

    interpreter.run(input, output);

    output = List.from(output.reshape([outputSize]));

    return output;
  }

  Future<List> runModelForCameraImage(
    CameraImage cameraImage,
    Face face,
  ) async {
    img_lib.Image image = await processImageFromCamera(cameraImage, face);
    return runModel(image);
  }

  Future<List> runModelForFileImage(
    File file,
    Face face,
  ) async {
    img_lib.Image image = processImageFromFile(file, face);
    return runModel(image);
  }

  Future<List> runModelForStudentImage(String imgUrl) async {
    img_lib.Image image = await processImageFromUrl(imgUrl);
    return runModel(image);
  }

  Future<Student> compareInputEmbeddingsWithStudents(
    List inputEmbeddings,
  ) async {
    // get all students
    final students = await FirebaseDataManager.getAllStudents();

    // initialize trackers
    Student? matchedIdentity;
    num minDistance = 999;

    for (final student in students) {
      if (student.imgUrl == null) continue;

      // calculate the distance between the camera face embeddings and the student face embeddings
      final distance = calculateEuclideanDistance(
        inputEmbeddings,
        student.embeddings,
      );

      print("${student.firstName}: $distance");

      // if the distance is lower than the threshold and the current lowest distance, update the trackers
      if (distance < minDistance) {
        matchedIdentity = student;
        minDistance = distance;
      }
    }

    return matchedIdentity!;
  }

  Future<Student> findMostSimilarIdentityFromFileImage({
    required File file,
    required Face face,
  }) async {
    final fileImageEmbeddings = await runModelForFileImage(file, face);
    return compareInputEmbeddingsWithStudents(fileImageEmbeddings);
  }

  Future<Student> findMostSimilarIdentity({
    required CameraImage cameraImage,
    required Face face,
  }) async {
    final cameraFeedEmbeddings =
        await runModelForCameraImage(cameraImage, face);
    return compareInputEmbeddingsWithStudents(cameraFeedEmbeddings);
  }
}
