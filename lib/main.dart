import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'providers/glasses_provider_simple.dart';
import 'screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GlassesProvider(),
      child: MaterialApp(
        title: 'VisionTry Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        home: CameraScreen(cameras: cameras),
      ),
    );
  }
}
