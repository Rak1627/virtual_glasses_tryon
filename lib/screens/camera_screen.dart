import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../providers/glasses_provider_simple.dart';
import '../widgets/glasses_painter.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isProcessing = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: false,
      enableClassification: false,
    ),
  );
  List<Face> _faces = [];
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    final camera = widget.cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();

    if (mounted) {
      setState(() => _isReady = true);
      _controller!.startImageStream(_processCameraImage);
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final faces = await _faceDetector.processImage(inputImage);
        if (mounted) {
          setState(() {
            _faces = faces;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
      }
    } catch (e) {
      // Handle errors silently
    }

    _isProcessing = false;
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      // Get image format
      InputImageFormat? format;
      if (image.format.group == ImageFormatGroup.yuv420) {
        format = InputImageFormat.yuv420;
      } else if (image.format.group == ImageFormatGroup.nv21) {
        format = InputImageFormat.nv21;
      } else {
        return null; // Unsupported format
      }

      // Get rotation (front camera is usually 270 or 90 degrees)
      final rotation = InputImageRotation.rotation270deg;

      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      // Debug: Print error in development
      if (mounted) {
        debugPrint('Face detection error: $e');
      }
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlassesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisionTry Store'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _isReady && _controller != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller!),
                      if (_faces.isNotEmpty && _imageSize != null && provider.selectedGlasses != 'None')
                        CustomPaint(
                          painter: GlassesPainter(
                            faces: _faces,
                            imageSize: _imageSize!,
                            screenSize: MediaQuery.of(context).size,
                            glassesType: provider.selectedGlasses,
                          ),
                        ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _faces.isEmpty ? 'No face detected' : '${_faces.length} face(s) detected',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selected: ${provider.selectedGlasses}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGlassCard(context, 'Wayfarer', '\$149.99', Colors.black87),
                        _buildGlassCard(context, 'Aviator', '\$179.99', const Color(0xFFFFD700)),
                        _buildGlassCard(context, 'Round', '\$129.99', const Color(0xFFFF6B9D)),
                        _buildGlassCard(context, 'Cat Eye', '\$139.99', Colors.purple),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.selectedGlasses != 'None')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${provider.selectedGlasses} added to cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Purchase'),
                                content: Text('Buy ${provider.selectedGlasses}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Order placed!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    child: const Text('Buy Now'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('Buy Now'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, String name, String price, Color color) {
    final provider = Provider.of<GlassesProvider>(context, listen: false);
    final isSelected = provider.selectedGlasses == name;

    return GestureDetector(
      onTap: () => provider.selectGlasses(name),
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(60, 25),
              painter: _GlassesPreviewPainter(name, color),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassesPreviewPainter extends CustomPainter {
  final String glassesType;
  final Color color;

  _GlassesPreviewPainter(this.glassesType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lensPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.save();

    if (glassesType.contains('Round')) {
      final radius = w * 0.15;
      canvas.drawCircle(Offset(cx - w * 0.25, cy), radius, lensPaint);
      canvas.drawCircle(Offset(cx - w * 0.25, cy), radius, paint);
      canvas.drawCircle(Offset(cx + w * 0.25, cy), radius, lensPaint);
      canvas.drawCircle(Offset(cx + w * 0.25, cy), radius, paint);
      canvas.drawLine(Offset(cx - w * 0.1, cy), Offset(cx + w * 0.1, cy), paint);
    } else if (glassesType.contains('Aviator')) {
      final path1 = Path()
        ..moveTo(cx - w * 0.42, cy - h * 0.2)
        ..quadraticBezierTo(cx - w * 0.25, cy - h * 0.6, cx - w * 0.08, cy - h * 0.2)
        ..quadraticBezierTo(cx - w * 0.08, cy + h * 0.4, cx - w * 0.25, cy + h * 0.5)
        ..quadraticBezierTo(cx - w * 0.42, cy + h * 0.4, cx - w * 0.42, cy - h * 0.2);

      final path2 = Path()
        ..moveTo(cx + w * 0.42, cy - h * 0.2)
        ..quadraticBezierTo(cx + w * 0.25, cy - h * 0.6, cx + w * 0.08, cy - h * 0.2)
        ..quadraticBezierTo(cx + w * 0.08, cy + h * 0.4, cx + w * 0.25, cy + h * 0.5)
        ..quadraticBezierTo(cx + w * 0.42, cy + h * 0.4, cx + w * 0.42, cy - h * 0.2);

      canvas.drawPath(path1, lensPaint);
      canvas.drawPath(path1, paint);
      canvas.drawPath(path2, lensPaint);
      canvas.drawPath(path2, paint);
      canvas.drawLine(Offset(cx - w * 0.075, cy - h * 0.1), Offset(cx + w * 0.075, cy - h * 0.1), paint);
    } else if (glassesType.contains('Cat')) {
      final leftLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - w * 0.25, cy), width: w * 0.35, height: h * 0.8),
        const Radius.circular(12),
      );
      final rightLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + w * 0.25, cy), width: w * 0.35, height: h * 0.8),
        const Radius.circular(12),
      );
      canvas.drawRRect(leftLens, lensPaint);
      canvas.drawRRect(leftLens, paint);
      canvas.drawRRect(rightLens, lensPaint);
      canvas.drawRRect(rightLens, paint);
      canvas.drawLine(Offset(cx - w * 0.075, cy), Offset(cx + w * 0.075, cy), paint);
    } else {
      // Wayfarer
      final leftLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - w * 0.25, cy), width: w * 0.35, height: h * 0.8),
        const Radius.circular(6),
      );
      final rightLens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + w * 0.25, cy), width: w * 0.35, height: h * 0.8),
        const Radius.circular(6),
      );
      canvas.drawRRect(leftLens, lensPaint);
      canvas.drawRRect(leftLens, paint);
      canvas.drawRRect(rightLens, lensPaint);
      canvas.drawRRect(rightLens, paint);
      canvas.drawLine(Offset(cx - w * 0.075, cy), Offset(cx + w * 0.075, cy), paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassesPreviewPainter oldDelegate) => false;
}
