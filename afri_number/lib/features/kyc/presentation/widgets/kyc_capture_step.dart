import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/responsive/responsive.dart';
import '../../domain/models/kyc_side.dart';

/// Étape de capture KYC avec aperçu caméra intégré dans l'application.
class KycCaptureStep extends StatefulWidget {
  const KycCaptureStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.side,
    required this.onCaptured,
    this.errorMessage,
    this.isBusy = false,
  });

  final String title;
  final String subtitle;
  final KycSide side;
  final Future<void> Function(String path) onCaptured;
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
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didUpdateWidget(covariant KycCaptureStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.side != widget.side) {
      final camera = _camera;
      _camera = null;
      _description = null;
      if (camera != null) unawaited(camera.dispose());
      _initializeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _camera = null;
      unawaited(camera.dispose());
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(description: _description);
    }
  }

  Future<void> _initializeCamera({CameraDescription? description}) async {
    if (_initializationInProgress) return;
    _initializationInProgress = true;
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
        throw const CameraException('CameraNotFound', 'No camera available');
      }
      final requestedDirection = widget.side == KycSide.face
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final selectedCamera = description ??
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
      if (!mounted) {
        await nextCamera.dispose();
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.space(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: r.fontSize(15),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: r.space(2)),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: r.fontSize(12),
              color: colors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Center(
              child: _initializing
                  ? CircularProgressIndicator(color: colors.primary)
                  : _cameraError != null
                  ? _CameraErrorView(
                      message: _cameraError!,
                      onRetry: _initializeCamera,
                    )
                  : camera == null || !camera.value.isInitialized
                  ? _CameraErrorView(
                      message: 'kyc.camera_err'.tr,
                      onRetry: _initializeCamera,
                    )
                  : _buildPreview(camera, r),
            ),
          ),
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
                  ),
                ),
              ),
            ),
          SizedBox(height: r.space(12)),
          SizedBox(
            width: double.infinity,
            height: r.heightOf(54),
            child: FilledButton.icon(
              onPressed: camera?.value.isInitialized == true &&
                      !_takingPicture &&
                      !widget.isBusy
                  ? _takePicture
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
        ],
      ),
    );
  }

  Widget _buildPreview(CameraController camera, Responsive r) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r.radius(24)),
        child: AspectRatio(
          aspectRatio: camera.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(camera),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.20),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
              Center(
                child: widget.side == KycSide.face
                    ? Container(
                        width: r.space(220),
                        height: r.space(280),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2.5),
                          borderRadius: BorderRadius.circular(r.space(140)),
                        ),
                      )
                    : FractionallySizedBox(
                        widthFactor: 0.88,
                        child: AspectRatio(
                          aspectRatio: 1.58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(r.radius(14)),
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: r.space(12),
                right: r.space(12),
                bottom: r.space(12),
                child: Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.fontSize(12),
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        Icon(Icons.no_photography_outlined, size: r.iconSize(42), color: colors.error),
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
