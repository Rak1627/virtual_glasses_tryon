import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisionTry',
      home: Scaffold(
        appBar: AppBar(title: const Text('VisionTry Store')),
        body: const Center(
          child: Text('Virtual Glasses Try-On App', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
