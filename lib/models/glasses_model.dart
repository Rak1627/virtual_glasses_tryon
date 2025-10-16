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
        name: 'Ray-Ban Wayfarer',
        imagePath: 'wayfarer',
        color: 'Classic Black',
        price: 149.99,
      ),
      GlassesModel(
        id: '2',
        name: 'Aviator Gold',
        imagePath: 'aviator',
        color: 'Gold Frame',
        price: 179.99,
      ),
      GlassesModel(
        id: '3',
        name: 'Round Vintage',
        imagePath: 'round',
        color: 'Rose Gold',
        price: 129.99,
      ),
      GlassesModel(
        id: '4',
        name: 'Cat Eye Fashion',
        imagePath: 'cateye',
        color: 'Tortoise Shell',
        price: 139.99,
      ),
    ];
  }
}
