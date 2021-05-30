import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  // isFavourite is not final because its mutable
  bool isFavourite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  Product copyWith({
    String id,
    String title,
    String description,
    double price,
    String imageUrl,
    bool isFavourite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
  /*
  !function moved to another place -  changed  
  void 
  toggleFavourite() {
    isFavourite = !isFavourite;
    notifyListeners();
  }
  */
}
