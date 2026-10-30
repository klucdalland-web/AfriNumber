import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/kyc_side.dart';
import '../../domain/services/kyc_camera_service.dart';

/// Implémentation de [KycCameraService] basée sur `image_picker`.
class ImagePickerKycCameraService implements KycCameraService {
  /// Crée le service ; un [ImagePicker] peut être injecté pour les tests.
  ImagePickerKycCameraService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> capture(KycSide side) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
        side == KycSide.face ? CameraDevice.front : CameraDevice.rear,
        maxWidth: 1600,
        imageQuality: 85,
      );
      return file?.path;
    } on PlatformException catch (e) {
      throw KycCameraException(denied: e.code == 'camera_access_denied');
    }
  }
}