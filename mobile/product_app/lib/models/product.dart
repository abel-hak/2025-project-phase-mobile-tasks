class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double rating;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
    required this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    double? rating,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
