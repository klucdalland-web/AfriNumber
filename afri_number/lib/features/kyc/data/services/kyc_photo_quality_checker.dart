import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Résultat du contrôle local de netteté, exposition et contraste.
class KycPhotoQualityResult {
  const KycPhotoQualityResult({required this.accepted, this.messageKey});

  final bool accepted;
  final String? messageKey;
}

/// Vérifie une photo avant qu'elle soit ajoutée au dossier envoyé au serveur.
class KycPhotoQualityChecker {
  Future<KycPhotoQualityResult> check(
    Uint8List bytes, {
    required bool isFace,
  }) async {
    try {
      return await compute(
        _analyzeKycPhoto,
        _KycPhotoAnalysisInput(bytes: bytes, isFace: isFace),
      );
    } catch (_) {
      return const KycPhotoQualityResult(
        accepted: false,
        messageKey: 'kyc.quality.unreadable',
      );
    }
  }
}

class _KycPhotoAnalysisInput {
  const _KycPhotoAnalysisInput({required this.bytes, required this.isFace});

  final Uint8List bytes;
  final bool isFace;
}

KycPhotoQualityResult _analyzeKycPhoto(_KycPhotoAnalysisInput input) {
  final source = img.decodeImage(input.bytes);
  if (source == null) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.unreadable',
    );
  }

  final shortSide = math.min(source.width, source.height);
  final longSide = math.max(source.width, source.height);
  if (shortSide < (input.isFace ? 480 : 600) ||
      (!input.isFace && longSide < 900)) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.low_resolution',
    );
  }

  // A small sample keeps the analysis quick even for full-resolution photos.
  final sample = img.copyResize(
    source,
    width: source.width < 320 ? source.width : 320,
  );
  final width = sample.width;
  final height = sample.height;
  final luminance = List<double>.filled(width * height, 0);
  var brightnessTotal = 0.0;
  var brightnessSquaredTotal = 0.0;
  var darkPixelCount = 0;
  var brightPixelCount = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = sample.getPixel(x, y);
      final value =
          0.2126 * pixel.r.toDouble() +
          0.7152 * pixel.g.toDouble() +
          0.0722 * pixel.b.toDouble();
      luminance[y * width + x] = value;
      brightnessTotal += value;
      brightnessSquaredTotal += value * value;
      if (value < 18) darkPixelCount++;
      if (value > 245) brightPixelCount++;
    }
  }

  final pixelCount = luminance.length;
  final brightness = brightnessTotal / pixelCount;
  final contrastVariance = math.max(
    0.0,
    (brightnessSquaredTotal / pixelCount) - (brightness * brightness),
  );
  final contrast = math.sqrt(contrastVariance);
  if (brightness < 48 || darkPixelCount / pixelCount > 0.42) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.too_dark',
    );
  }
  if (brightness > 218 || brightPixelCount / pixelCount > 0.38) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.too_bright',
    );
  }

  var laplacianTotal = 0.0;
  var laplacianSquaredTotal = 0.0;
  var edgeCount = 0;
  var sampleCount = 0;
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final index = y * width + x;
      final laplacian =
          4 * luminance[index] -
          luminance[index - 1] -
          luminance[index + 1] -
          luminance[index - width] -
          luminance[index + width];
      laplacianTotal += laplacian;
      laplacianSquaredTotal += laplacian * laplacian;
      if (laplacian.abs() > 16) edgeCount++;
      sampleCount++;
    }
  }

  final averageLaplacian = laplacianTotal / sampleCount;
  final sharpness =
      (laplacianSquaredTotal / sampleCount) -
      (averageLaplacian * averageLaplacian);
  final edgeDensity = edgeCount / sampleCount;
  final minimumSharpness = input.isFace ? 18.0 : 32.0;
  if (sharpness < minimumSharpness) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.blurry',
    );
  }

  if (!input.isFace && edgeDensity < 0.003) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.content_unclear',
    );
  }
  if (contrast < (input.isFace ? 12 : 22)) {
    return const KycPhotoQualityResult(
      accepted: false,
      messageKey: 'kyc.quality.content_unclear',
    );
  }

  return const KycPhotoQualityResult(accepted: true);
}
