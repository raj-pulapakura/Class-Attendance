import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imgLib;

class FaceComparison {
  late Interpreter interpreter;

  initializeInterperter() async {
    Delegate? delegate;

    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
            inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
            inferencePriority1: TfLiteGpuInferencePriority.minLatency,
            inferencePriority2: TfLiteGpuInferencePriority.auto,
            inferencePriority3: TfLiteGpuInferencePriority.auto,
          ),
        );
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            waitType: TFLGpuDelegateWaitType.active,
          ),
        );
      }

      final interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      interpreter = await Interpreter.fromAsset(
        "mobilefacenet.tflite",
        options: interpreterOptions,
      );
    } catch (e) {
      print(e);
    }
  }

  List processImage(CameraImage image) {
    return [];
  }

  Future<String> findMostSimilarIdentity({
    required CameraImage cameraImage,
    required Face face,
  }) async {
    await initializeInterperter();

    List output = List.generate(1, (index) => List.filled(192, 0));

    return "";
  }
}
