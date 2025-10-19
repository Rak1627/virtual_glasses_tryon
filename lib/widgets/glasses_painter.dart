import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class GlassesPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size screenSize;
  final String glassesType;

  GlassesPainter({
    required this.faces,
    required this.imageSize,
    required this.screenSize,
    required this.glassesType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    for (final face in faces) {
      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final rightEye = face.landmarks[FaceLandmarkType.rightEye];

      if (leftEye != null && rightEye != null) {
        final scaleX = screenSize.width / imageSize.width;
        final scaleY = screenSize.height / imageSize.height;

        final leftPos = Offset(
          leftEye.position.x.toDouble() * scaleX,
          leftEye.position.y.toDouble() * scaleY,
        );
        final rightPos = Offset(
          rightEye.position.x.toDouble() * scaleX,
          rightEye.position.y.toDouble() * scaleY,
        );

        final glassesWidth = (rightPos.dx - leftPos.dx) * 2.5;
        final glassesHeight = glassesWidth * 0.4;
        final centerX = (leftPos.dx + rightPos.dx) / 2;
        final centerY = (leftPos.dy + rightPos.dy) / 2 - glassesHeight * 0.1;

        _drawGlasses(canvas, centerX, centerY, glassesWidth, glassesHeight);
      }
    }
  }

  void _drawGlasses(Canvas canvas, double cx, double cy, double w, double h) {
    final paint = Paint()
      ..color = _getGlassesColor()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final lensPaint = Paint()
      ..color = _getGlassesColor().withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);

    // Draw based on glasses type
    if (glassesType.contains('Round')) {
      _drawRoundGlasses(canvas, w, h, paint, lensPaint);
    } else if (glassesType.contains('Aviator')) {
      _drawAviatorGlasses(canvas, w, h, paint, lensPaint);
    } else if (glassesType.contains('Cat')) {
      _drawCatEyeGlasses(canvas, w, h, paint, lensPaint);
    } else {
      _drawWayfarerGlasses(canvas, w, h, paint, lensPaint);
    }

    canvas.restore();
  }

  void _drawWayfarerGlasses(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final leftLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.25, 0), width: w * 0.35, height: h),
      const Radius.circular(8),
    );
    final rightLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.25, 0), width: w * 0.35, height: h),
      const Radius.circular(8),
    );

    canvas.drawRRect(leftLens, fill);
    canvas.drawRRect(leftLens, stroke);
    canvas.drawRRect(rightLens, fill);
    canvas.drawRRect(rightLens, stroke);
    canvas.drawLine(Offset(-w * 0.075, 0), Offset(w * 0.075, 0), stroke);
  }

  void _drawRoundGlasses(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final radius = w * 0.175;
    canvas.drawCircle(Offset(-w * 0.25, 0), radius, fill);
    canvas.drawCircle(Offset(-w * 0.25, 0), radius, stroke);
    canvas.drawCircle(Offset(w * 0.25, 0), radius, fill);
    canvas.drawCircle(Offset(w * 0.25, 0), radius, stroke);
    canvas.drawLine(Offset(-w * 0.075, 0), Offset(w * 0.075, 0), stroke);
  }

  void _drawAviatorGlasses(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final path1 = Path()
      ..moveTo(-w * 0.42, -h * 0.2)
      ..quadraticBezierTo(-w * 0.25, -h * 0.6, -w * 0.08, -h * 0.2)
      ..quadraticBezierTo(-w * 0.08, h * 0.4, -w * 0.25, h * 0.5)
      ..quadraticBezierTo(-w * 0.42, h * 0.4, -w * 0.42, -h * 0.2);

    final path2 = Path()
      ..moveTo(w * 0.42, -h * 0.2)
      ..quadraticBezierTo(w * 0.25, -h * 0.6, w * 0.08, -h * 0.2)
      ..quadraticBezierTo(w * 0.08, h * 0.4, w * 0.25, h * 0.5)
      ..quadraticBezierTo(w * 0.42, h * 0.4, w * 0.42, -h * 0.2);

    canvas.drawPath(path1, fill);
    canvas.drawPath(path1, stroke);
    canvas.drawPath(path2, fill);
    canvas.drawPath(path2, stroke);
    canvas.drawLine(Offset(-w * 0.075, -h * 0.1), Offset(w * 0.075, -h * 0.1), stroke);
  }

  void _drawCatEyeGlasses(Canvas canvas, double w, double h, Paint stroke, Paint fill) {
    final leftLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.25, 0), width: w * 0.35, height: h),
      const Radius.circular(16),
    );
    final rightLens = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.25, 0), width: w * 0.35, height: h),
      const Radius.circular(16),
    );

    canvas.drawRRect(leftLens, fill);
    canvas.drawRRect(leftLens, stroke);
    canvas.drawRRect(rightLens, fill);
    canvas.drawRRect(rightLens, stroke);
    canvas.drawLine(Offset(-w * 0.075, 0), Offset(w * 0.075, 0), stroke);
  }

  Color _getGlassesColor() {
    if (glassesType.contains('Aviator')) return const Color(0xFFFFD700);
    if (glassesType.contains('Round')) return const Color(0xFFFF6B9D);
    if (glassesType.contains('Cat')) return Colors.purple;
    return Colors.black87;
  }

  @override
  bool shouldRepaint(GlassesPainter oldDelegate) => oldDelegate.faces != faces;
}
