import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class GlassesOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size widgetSize;
  final String? glassesImagePath;

  GlassesOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.widgetSize,
    this.glassesImagePath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;

    for (final Face face in faces) {
      // Draw face boundary (for debugging)
      // final Rect boundingBox = _scaleRect(
      //   rect: face.boundingBox,
      //   imageSize: imageSize,
      //   widgetSize: widgetSize,
      // );
      // canvas.drawRect(boundingBox, paint);

      // Get eye positions for glasses placement
      final FaceLandmark? leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final FaceLandmark? rightEye = face.landmarks[FaceLandmarkType.rightEye];
      final FaceLandmark? noseBase = face.landmarks[FaceLandmarkType.noseBase];

      if (leftEye != null && rightEye != null && noseBase != null) {
        // Scale eye positions
        final leftEyePos = _scalePoint(
          point: leftEye.position,
          imageSize: imageSize,
          widgetSize: widgetSize,
        );
        final rightEyePos = _scalePoint(
          point: rightEye.position,
          imageSize: imageSize,
          widgetSize: widgetSize,
        );
        final nosePos = _scalePoint(
          point: noseBase.position,
          imageSize: imageSize,
          widgetSize: widgetSize,
        );

        // Calculate glasses dimensions and position
        final glassesWidth = (rightEyePos.dx - leftEyePos.dx) * 2.2;
        final glassesHeight = glassesWidth * 0.4;

        // Center position between eyes, slightly above
        final centerX = (leftEyePos.dx + rightEyePos.dx) / 2;
        final centerY = (leftEyePos.dy + rightEyePos.dy) / 2 - glassesHeight * 0.2;

        // Calculate rotation angle based on eye positions
        final angle = _calculateAngle(leftEyePos, rightEyePos);

        // Draw glasses frame (simple representation)
        canvas.save();
        canvas.translate(centerX, centerY);
        canvas.rotate(angle);

        // Draw a simple glasses representation
        _drawGlasses(canvas, glassesWidth, glassesHeight);

        canvas.restore();
      }
    }
  }

  void _drawGlasses(Canvas canvas, double width, double height) {
    // Determine style based on glassesImagePath
    final isAviator = glassesImagePath?.contains('aviator') ?? false;
    final isRound = glassesImagePath?.contains('round') ?? false;
    final isCateye = glassesImagePath?.contains('cateye') ?? false;

    final Paint glassesPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = isAviator ? const Color(0xFFFFD700) : Colors.black87;

    final Paint lensPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isAviator ? Colors.amber : Colors.blue).withOpacity(0.15);

    // Left lens
    final leftLensRect = Rect.fromCenter(
      center: Offset(-width * 0.25, 0),
      width: width * 0.35,
      height: height,
    );

    if (isRound) {
      // Circular lenses for round glasses
      canvas.drawCircle(Offset(-width * 0.25, 0), width * 0.175, lensPaint);
      canvas.drawCircle(Offset(-width * 0.25, 0), width * 0.175, glassesPaint);
    } else if (isAviator) {
      // Teardrop shape for aviators
      final path = Path()
        ..moveTo(-width * 0.42, -height * 0.2)
        ..quadraticBezierTo(-width * 0.25, -height * 0.6, -width * 0.08, -height * 0.2)
        ..quadraticBezierTo(-width * 0.08, height * 0.4, -width * 0.25, height * 0.5)
        ..quadraticBezierTo(-width * 0.42, height * 0.4, -width * 0.42, -height * 0.2);
      canvas.drawPath(path, lensPaint);
      canvas.drawPath(path, glassesPaint);
    } else {
      // Standard rounded rectangle
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftLensRect, Radius.circular(isCateye ? 16 : 8)),
        lensPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftLensRect, Radius.circular(isCateye ? 16 : 8)),
        glassesPaint,
      );
    }

    // Right lens (mirror of left)
    final rightLensRect = Rect.fromCenter(
      center: Offset(width * 0.25, 0),
      width: width * 0.35,
      height: height,
    );

    if (isRound) {
      canvas.drawCircle(Offset(width * 0.25, 0), width * 0.175, lensPaint);
      canvas.drawCircle(Offset(width * 0.25, 0), width * 0.175, glassesPaint);
    } else if (isAviator) {
      final path = Path()
        ..moveTo(width * 0.42, -height * 0.2)
        ..quadraticBezierTo(width * 0.25, -height * 0.6, width * 0.08, -height * 0.2)
        ..quadraticBezierTo(width * 0.08, height * 0.4, width * 0.25, height * 0.5)
        ..quadraticBezierTo(width * 0.42, height * 0.4, width * 0.42, -height * 0.2);
      canvas.drawPath(path, lensPaint);
      canvas.drawPath(path, glassesPaint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightLensRect, Radius.circular(isCateye ? 16 : 8)),
        lensPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightLensRect, Radius.circular(isCateye ? 16 : 8)),
        glassesPaint,
      );
    }

    // Bridge
    canvas.drawLine(
      Offset(-width * 0.075, 0),
      Offset(width * 0.075, 0),
      glassesPaint,
    );

    // Left temple
    canvas.drawLine(
      Offset(-width * 0.42, 0),
      Offset(-width * 0.5, height * 0.1),
      glassesPaint,
    );

    // Right temple
    canvas.drawLine(
      Offset(width * 0.42, 0),
      Offset(width * 0.5, height * 0.1),
      glassesPaint,
    );
  }

  Offset _scalePoint({
    required Point<int> point,
    required Size imageSize,
    required Size widgetSize,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Offset(
      point.x.toDouble() * scaleX,
      point.y.toDouble() * scaleY,
    );
  }

  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size widgetSize,
  }) {
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
  }

  double _calculateAngle(Offset leftEye, Offset rightEye) {
    final double deltaY = rightEye.dy - leftEye.dy;
    final double deltaX = rightEye.dx - leftEye.dx;
    return deltaY / deltaX;
  }

  @override
  bool shouldRepaint(GlassesOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
