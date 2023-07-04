import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

imglib.Image? convertToImage(CameraImage image) {
  if (image.format.group == ImageFormatGroup.yuv420) {
    return _convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return _convertBGRA8888(image);
  } else {
    throw Exception('Image format not supported');
  }
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
  const shift = (0xFF << 24);
  // for each pixel, extract the YUV values and convert to RGB, then set the pixel in the empty image
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data!.setPixelR(x, y, shift | (b << 16) | (g << 8) | r);
    }
  }

  return img;
}
