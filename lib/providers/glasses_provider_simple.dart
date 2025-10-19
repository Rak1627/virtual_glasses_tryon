import 'package:flutter/material.dart';

class GlassesProvider extends ChangeNotifier {
  String _selectedGlasses = 'None';

  String get selectedGlasses => _selectedGlasses;

  void selectGlasses(String name) {
    _selectedGlasses = name;
    notifyListeners();
  }
}
