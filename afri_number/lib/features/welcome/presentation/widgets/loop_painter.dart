import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class LoopPainter extends CustomPainter {
  final Color color;

  LoopPainter({
    this.color = Colors.black,
  });

  static const String _loopSvgPath =
      'M2.00008 76.1065C11.8573 84.323 22.6511 90.2544 35.1247 94.7417C51.332 100.572 73.3058 101.871 87.6438 95.5448C98.9212 90.5694 114.057 80.1793 112.249 67.0398C110.477 54.1618 98.1809 38.1592 82.9946 34.0919C73.2712 31.4878 65.5394 37.9792 61.4936 44.4075C57.4326 50.8599 59.8579 57.9026 67.5243 63.0189C73.9929 67.3359 80.1477 68.4057 87.5744 68.7818C98.8869 69.3547 110.875 68.3604 121.186 65.5142C132.752 62.3216 144.132 58.5919 151.618 50.2801C163.698 36.8665 167.207 19.2396 170.327 2.00035';

  static final Path _cachedPath = parseSvgPathData(_loopSvgPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 173;
    final scaleY = size.height / 102;
    final matrix = Matrix4.identity()..scale(scaleX, scaleY);

    canvas.drawPath(_cachedPath.transform(matrix.storage), paint);
  }

  @override
  bool shouldRepaint(covariant LoopPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}