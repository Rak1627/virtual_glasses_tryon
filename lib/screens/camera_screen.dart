import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../providers/glasses_provider_simple.dart';
import '../widgets/glasses_painter.dart';
import 'dart:async';
import 'dart:typed_data';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isReady = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );
  List<Face> _faces = [];
  bool _isProcessing = false;
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
      final inputImage = _buildInputImage(image);
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
      // Silently handle errors
    }

    _isProcessing = false;
  }

  InputImage? _buildInputImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
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
                            _faces.isEmpty ? 'No face detected' : '${_faces.length} face(s)',
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
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildGlassButton(context, 'Wayfarer', '\$149.99'),
                      _buildGlassButton(context, 'Aviator', '\$179.99'),
                      _buildGlassButton(context, 'Round', '\$129.99'),
                      _buildGlassButton(context, 'Cat Eye', '\$139.99'),
                    ],
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

  Widget _buildGlassButton(BuildContext context, String name, String price) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<GlassesProvider>(context, listen: false).selectGlasses(name);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          Text(price, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
