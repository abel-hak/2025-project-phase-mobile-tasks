class Product {
  String _name;
  String _description;
  double _price;

  Product(this._name, this._description, this._price);

  // Getters
  String get name => _name;
  String get description => _description;
  double get price => _price;

  // Setters
  set name(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    _name = value;
  }

  set description(String value) {
    if (value.isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
    _description = value;
  }

  set price(double value) {
    if (value < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    _price = value;
  }

  @override
  String toString() {
    return 'Product: $name\nDescription: $description\nPrice: \$${price.toStringAsFixed(2)}';
  }
}
