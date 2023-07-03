import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

imglib.Image? convertToImage(CameraImage image) {
  print(image.format.group);
  if (image.format.group == ImageFormatGroup.yuv420) {
    // this would be for ios devices
    return _convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return _convertBGRA8888(image);
  } else {
    throw Exception('Image format not supported');
  }
  return null;
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
  );
}

imglib.Image _convertYUV420(CameraImage image) {
  // image conversion formulas: https://www.pcmag.com/encyclopedia/term/yuvrgb-conversion-formulas

  // create empty image
  int width = image.width;
  int height = image.height;
  var img = imglib.Image(width: width, height: height);

  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;

  // for each pixel, extract the YUV values and convert to RGB, then set the pixel in the empty image
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + 1.14 * vp).round().clamp(0, 255);
      int g = (yp - 0.395 * up - 0.518 * vp).round().clamp(0, 255);
      int b = (yp + 2.032 * up).round().clamp(0, 255);

      img.setPixel(x, y, imglib.ColorFloat32.rgb(r, g, b));
    }
  }

  return img;
}
