class GlassesModel {
  final String id;
  final String name;
  final String imagePath;
  final String color;
  final double price;

  GlassesModel({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.color,
    required this.price,
  });

  static List<GlassesModel> getSampleGlasses() {
    return [
      GlassesModel(
        id: '1',
        name: 'Classic Wayfarer',
        imagePath: 'assets/glasses/wayfarer.png',
        color: 'Black',
        price: 99.99,
      ),
      GlassesModel(
        id: '2',
        name: 'Round Vintage',
        imagePath: 'assets/glasses/round.png',
        color: 'Gold',
        price: 89.99,
      ),
      GlassesModel(
        id: '3',
        name: 'Aviator',
        imagePath: 'assets/glasses/aviator.png',
        color: 'Silver',
        price: 119.99,
      ),
      GlassesModel(
        id: '4',
        name: 'Cat Eye',
        imagePath: 'assets/glasses/cateye.png',
        color: 'Tortoise',
        price: 94.99,
      ),
      GlassesModel(
        id: '5',
        name: 'Square Frame',
        imagePath: 'assets/glasses/square.png',
        color: 'Blue',
        price: 79.99,
      ),
      GlassesModel(
        id: '6',
        name: 'Vinyl Clear',
        imagePath: 'assets/glasses/vinyl.png',
        color: 'Clear Yellow',
        price: 85.99,
      ),
    ];
  }
}
