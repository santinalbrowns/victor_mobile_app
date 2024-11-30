class Product {
  final int id;
  final String name;
  final String description;
  final String sku;
  final int categoryId;
  final bool status;
  final bool visibility;
  final String? image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    required this.categoryId,
    required this.status,
    required this.visibility,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Get the first image if available
    String? imageUrl;
    if (json['images'] != null && json['images'].isNotEmpty) {
      imageUrl = json['images'][0]['name'];
    }

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sku: json['sku'],
      categoryId: json['category_id'],
      status: json['status'],
      visibility: json['visibility'],
      image: imageUrl,
    );
  }
}
