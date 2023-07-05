class Product {
  const Product({
    required this.id,
    required this.user,
    required this.name,
    required this.price,
    required this.description,
    required this.imageURL,
  });

  final int id;
  final String user;
  final String name;
  final String price;
  final String description;
  final String imageURL;



  String get assetName => '$id-0.jpg';
  String get assetPackage => 'shrine_images';

  @override
  String toString() => "$name (id=$id)";
}
