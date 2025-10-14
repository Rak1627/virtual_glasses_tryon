import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../providers/glasses_provider.dart';
import '../services/face_detector_service.dart';
import '../widgets/glasses_overlay_painter.dart';
import '../models/glasses_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  final FaceDetectorService _faceDetectorService = FaceDetectorService();
  List<Face> _faces = [];
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available');
        return;
      }

      // Use front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isDetecting) return;

    _isDetecting = true;
    _imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    try {
      final faces = await _faceDetectorService.detectFaces(cameraImage);
      if (mounted) {
        setState(() {
          _faces = faces;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo saved: ${image.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  void _showGlassesSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const GlassesSelectorSheet(),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Glasses Try-On'),
        actions: [
          Consumer<GlassesProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.showGlasses ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  provider.toggleGlassesVisibility();
                },
              );
            },
          ),
        ],
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildCameraPreview(),
                ),
                Expanded(
                  child: _buildControlPanel(),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _capturePhoto,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        Consumer<GlassesProvider>(
          builder: (context, provider, _) {
            if (_faces.isNotEmpty &&
                provider.selectedGlasses != null &&
                provider.showGlasses &&
                _imageSize != null) {
              return CustomPaint(
                painter: GlassesOverlayPainter(
                  faces: _faces,
                  imageSize: _imageSize!,
                  widgetSize: MediaQuery.of(context).size,
                  glassesImagePath: provider.selectedGlasses!.imagePath,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          top: 16,
          left: 16,
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
    );
  }

  Widget _buildControlPanel() {
    return Consumer<GlassesProvider>(
      builder: (context, provider, _) {
        return Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showGlassesSelector,
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Select Glasses'),
                    ),
                    if (provider.selectedGlasses != null)
                      ElevatedButton.icon(
                        onPressed: () => provider.removeGlasses(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              if (provider.selectedGlasses != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye),
                      title: Text(provider.selectedGlasses!.name),
                      subtitle: Text('${provider.selectedGlasses!.color} - \$${provider.selectedGlasses!.price}'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GlassesSelectorSheet extends StatelessWidget {
  const GlassesSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlassesProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Glasses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.allGlasses.length,
              itemBuilder: (context, index) {
                final glasses = provider.allGlasses[index];
                final isSelected = provider.selectedGlasses?.id == glasses.id;

                return GestureDetector(
                  onTap: () {
                    provider.selectGlasses(glasses);
                    Navigator.pop(context);
                  },
                  child: Card(
                    elevation: isSelected ? 8 : 2,
                    color: isSelected ? Colors.blue[50] : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.remove_red_eye,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                glasses.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                glasses.color,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '\$${glasses.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
