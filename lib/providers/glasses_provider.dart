import 'package:flutter/material.dart';
import '../models/glasses_model.dart';

class GlassesProvider extends ChangeNotifier {
  List<GlassesModel> _allGlasses = [];
  GlassesModel? _selectedGlasses;
  bool _showGlasses = true;

  GlassesProvider() {
    _allGlasses = GlassesModel.getSampleGlasses();
  }

  List<GlassesModel> get allGlasses => _allGlasses;
  GlassesModel? get selectedGlasses => _selectedGlasses;
  bool get showGlasses => _showGlasses;

  void selectGlasses(GlassesModel glasses) {
    _selectedGlasses = glasses;
    _showGlasses = true;
    notifyListeners();
  }

  void toggleGlassesVisibility() {
    _showGlasses = !_showGlasses;
    notifyListeners();
  }

  void removeGlasses() {
    _selectedGlasses = null;
    notifyListeners();
  }
}
