import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/glasses_provider_simple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GlassesProvider(),
      child: MaterialApp(
        title: 'VisionTry Store',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VisionTry Store')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_red_eye, size: 100, color: Colors.indigo),
            const SizedBox(height: 20),
            Consumer<GlassesProvider>(
              builder: (context, provider, _) {
                return Text(
                  'Selected: ${provider.selectedGlasses}',
                  style: const TextStyle(fontSize: 20),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<GlassesProvider>(context, listen: false)
                    .selectGlasses('Ray-Ban Wayfarer');
              },
              child: const Text('Try Glasses'),
            ),
          ],
        ),
      ),
    );
  }
}
