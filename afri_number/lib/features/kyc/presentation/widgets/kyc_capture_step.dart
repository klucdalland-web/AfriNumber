import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive.dart';
import '../../data/services/kyc_photo_quality_checker.dart';
import '../../domain/models/kyc_side.dart';

/// Étape de capture KYC avec aperçu caméra intégré dans l'application.
class KycCaptureStep extends StatefulWidget {
  const KycCaptureStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.side,
    required this.onCaptured,
    required this.onQualityResult,
    this.errorMessage,
    this.isBusy = false,
  });

  final String title;
  final String subtitle;
  final KycSide side;
  final Future<void> Function(String path) onCaptured;
  final void Function(bool accepted, String? messageKey) onQualityResult;
  final String? errorMessage;
  final bool isBusy;

  @override
  State<KycCaptureStep> createState() => _KycCaptureStepState();
}

class _KycCaptureStepState extends State<KycCaptureStep>
    with WidgetsBindingObserver {
  CameraController? _camera;
  CameraDescription? _description;
  bool _initializing = true;
  bool _initializationInProgress = false;
  bool _takingPicture = false;
  bool _cameraShouldBeOpen = true;
  String? _cameraError;
  final KycPhotoQualityChecker _qualityChecker = KycPhotoQualityChecker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCamera());
  }

  @override
  void didUpdateWidget(covariant KycCaptureStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.side != widget.side) {
      final camera = _camera;
      _camera = null;
      _description = null;
      unawaited(_replaceCamera(camera));
    }
  }

  Future<void> _replaceCamera(CameraController? previousCamera) async {
    if (previousCamera != null) await previousCamera.dispose();
    if (mounted && _cameraShouldBeOpen) await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _cameraShouldBeOpen = state == AppLifecycleState.resumed;
    final camera = _camera;
    if (camera == null) {
      if (_cameraShouldBeOpen) {
        unawaited(_initializeCamera(description: _description));
      }
      return;
    }

    if (!_cameraShouldBeOpen) {
      _camera = null;
      unawaited(_replaceCamera(camera));
    } else {
      unawaited(_initializeCamera(description: _description));
    }
  }

  Future<void> _initializeCamera({CameraDescription? description}) async {
    if (_initializationInProgress || !_cameraShouldBeOpen) return;
    _initializationInProgress = true;
    final sideAtStart = widget.side;
    if (mounted) {
      setState(() {
        _initializing = true;
        _cameraError = null;
      });
    }

    CameraController? nextCamera;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('CameraNotFound', 'No camera available');
      }
      final requestedDirection = widget.side == KycSide.face
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final selectedCamera =
          description ??
          cameras.firstWhere(
            (camera) => camera.lensDirection == requestedDirection,
            orElse: () => cameras.first,
          );
      _description = selectedCamera;

      nextCamera = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await nextCamera.initialize();
      if (!mounted || !_cameraShouldBeOpen || sideAtStart != widget.side) {
        await nextCamera.dispose();
        if (mounted && _cameraShouldBeOpen && sideAtStart != widget.side) {
          _cameraShouldBeOpen = true;
          _initializeAfterCurrentAttempt();
        }
        return;
      }
      _camera = nextCamera;
    } on CameraException catch (error) {
      if (mounted) setState(() => _cameraError = _messageFor(error));
      if (nextCamera != null) unawaited(nextCamera.dispose());
    } catch (_) {
      if (mounted) setState(() => _cameraError = 'kyc.camera_err'.tr);
      if (nextCamera != null) unawaited(nextCamera.dispose());
    } finally {
      _initializationInProgress = false;
      if (mounted) setState(() => _initializing = false);
    }
  }

  void _initializeAfterCurrentAttempt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initializeCamera());
    });
  }

  String _messageFor(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
      case 'camera_access_denied':
        return 'kyc.camera_denied'.tr;
      default:
        return 'kyc.camera_err'.tr;
    }
  }

  Future<void> _takePicture() async {
    final camera = _camera;
    if (camera == null ||
        !camera.value.isInitialized ||
        _takingPicture ||
        widget.isBusy) {
      return;
    }

    setState(() => _takingPicture = true);
    try {
      final image = await camera.takePicture();
      final bytes = await image.readAsBytes();
      final quality = await _qualityChecker.check(
        bytes,
        isFace: widget.side == KycSide.face,
      );
      if (!mounted) return;
      widget.onQualityResult(quality.accepted, quality.messageKey);
      if (!quality.accepted) return;
      await widget.onCaptured(image.path);
    } on CameraException catch (error) {
      if (mounted) setState(() => _cameraError = _messageFor(error));
    } catch (_) {
      if (mounted) setState(() => _cameraError = 'kyc.camera_err'.tr);
    } finally {
      if (mounted) setState(() => _takingPicture = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final camera = _camera;
    _camera = null;
    if (camera != null) unawaited(camera.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    final camera = _camera;

    const textShadow = [Shadow(color: Colors.black54, blurRadius: 6)];

    Widget background;
    if (_initializing) {
      background = Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    } else if (_cameraError != null) {
      background = Center(
        child: _CameraErrorView(
          message: _cameraError!,
          onRetry: () => unawaited(_initializeCamera()),
        ),
      );
    } else if (camera == null || !camera.value.isInitialized) {
      background = Center(
        child: _CameraErrorView(
          message: 'kyc.camera_err'.tr,
          onRetry: () => unawaited(_initializeCamera()),
        ),
      );
    } else {
      background = _buildPreview(context, camera, r);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Aperçu plein écran
        Positioned.fill(child: background),

        // Interface par-dessus l'aperçu
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: r.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.space(8)),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: r.fontSize(15),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: textShadow,
                  ),
                ),
                SizedBox(height: r.space(2)),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: r.fontSize(12),
                    color: Colors.white70,
                    shadows: textShadow,
                  ),
                ),
                const Spacer(),
                if (widget.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: r.space(8)),
                    child: Center(
                      child: Text(
                        widget.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: r.fontSize(12),
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                          shadows: textShadow,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: r.heightOf(54),
                  child: FilledButton.icon(
                    onPressed:
                        camera?.value.isInitialized == true &&
                            !_takingPicture &&
                            !widget.isBusy
                        ? () => unawaited(_takePicture())
                        : null,
                    icon: _takingPicture || widget.isBusy
                        ? SizedBox(
                            width: r.iconSize(18),
                            height: r.iconSize(18),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded),
                    label: Text('kyc.take_photo'.tr),
                  ),
                ),
                SizedBox(height: r.space(12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(
    BuildContext context,
    CameraController camera,
    Responsive r,
  ) {
    final previewSize = camera.value.previewSize!;
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    // previewSize est fourni en paysage : on l'inverse en portrait.
    final previewWidth = isPortrait ? previewSize.height : previewSize.width;
    final previewHeight = isPortrait ? previewSize.width : previewSize.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Plein écran, ratio conservé (rogné au lieu d'étiré)
        ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: CameraPreview(camera),
            ),
          ),
        ),

        // Masque sombre + cadre blanc de référence
        LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final center = size.center(Offset.zero);

            final RRect frame;
            if (widget.side == KycSide.face) {
              final w = r.space(220);
              final h = r.space(280);
              frame = RRect.fromRectAndRadius(
                Rect.fromCenter(center: center, width: w, height: h),
                Radius.circular(w / 2),
              );
            } else {
              final w = size.width * 0.88;
              final h = w / 1.58;
              frame = RRect.fromRectAndRadius(
                Rect.fromCenter(center: center, width: w, height: h),
                Radius.circular(r.radius(14)),
              );
            }

            return CustomPaint(
              size: size,
              painter: _FrameMaskPainter(frame: frame),
            );
          },
        ),
      ],
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.no_photography_outlined,
          size: r.iconSize(42),
          color: colors.error,
        ),
        SizedBox(height: r.space(12)),
        Text(message, textAlign: TextAlign.center),
        SizedBox(height: r.space(8)),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('common.retry'.tr),
        ),
      ],
    );
  }
}

class _FrameMaskPainter extends CustomPainter {
  _FrameMaskPainter({required this.frame});

  final RRect frame;

  @override
  void paint(Canvas canvas, Size size) {
    // Zone assombrie autour du cadre
    final mask = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(frame),
    );
    canvas.drawPath(mask, Paint()..color = Colors.black.withOpacity(0.45));

    // Cadre blanc
    canvas.drawRRect(
      frame,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FrameMaskPainter old) => old.frame != frame;
}
