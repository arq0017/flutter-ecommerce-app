import 'dart:convert';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String authToken, authUserId;

  List<Product> _items = [
    /* Product(
      id: 'p1',
      title: ' Shirt',
      description: 'A shirt with floral design , giving summer beach look . ',
      price: 29.99,
      imageUrl:
          'https://rukminim1.flixcart.com/image/714/857/kfwvcsw0-0/fabric/p/6/w/no-unstitched-az-393-avzira-original-imafw97jnhtchzue.jpeg?q=50',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'Trimmer',
      description: 'Trim your beard for alpha look.',
      price: 49.99,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT0WW5EuXPvz9mesp0baGYefsqA6VCB_B4PT5bWai2usaa7VZk4BzWSgpDZ2YMiJ7AOYwM&usqp=CAU',
    ),
    Product(
      id: 'p5',
      title: 'Car',
      description:
          'Hyundai E-car , an electric vehicle that runs on 120 watt powered batteries',
      price: 20049.99,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGnlc-AujAgkRGS0DDncpirop3vnnAjwYkabc-m41yPZWDTLkeLZYm2QkQgTC6mCI3Yzc&usqp=CAU',
    )
    */
  ];
  Products(this.authToken, this.authUserId, this._items);
  // var _showFavouritesOnly = false;
  /* if user want to access data somewhere else then copy of _items as items will be used .
  void isFavourite() {
    _showFavouritesOnly = true;
    notifyListeners();
  }

  void isAll() {
    _showFavouritesOnly = false;
    notifyListeners();
  }*/
  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="userId"&equalTo="$authUserId"' : '';
    var url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url);
      List<Product> loadingList = [];
      final serverProducts =
          (json.decode(response.body)) as Map<String, dynamic>;
      if (serverProducts == null) return;

      url = Uri.parse(
          'https://shopappflutter-d8463-default-rtdb.firebaseio.com/userFavourites/$authUserId.json?auth=$authToken');
      final isFavResponse = await http.get(url);
      final serverFavourites =
          (json.decode(isFavResponse.body)) as Map<String, dynamic>;
      serverProducts.forEach((key, value) {
        loadingList.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'].toDouble(),
          imageUrl: value['imageUrl'],
          isFavourite:
              serverFavourites == null ? false : serverFavourites[key] ?? false,
        ));
      });
      _items = loadingList;
      notifyListeners();
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<void> addProduct(Product product) async {
    // sending http request
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'userId': authUserId,
          'test': 'i failed in test',
        }),
      );

      final newProduct = Product(
        //? response type - map ( key name and value )
        //* Always use backend ID . Later can be used for matching with frontend

        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    //! CatchError removed - instead using try and catch

    // logic - simply copying the data to other object and adding new id with it
  }

  Future<void> updateProduct(Product newProduct, String id) async {
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
          /*
          ! ifFavourite not included - Have not done anything with isFav in editScreen 
          ! dont want to unnecessary update the isFavourite on server . 
          ! The value will remain same although . 
          */
        }));
    final productId = _items.indexWhere((element) => element.id == id);
    _items[productId] = newProduct;
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    // 1. get url
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    // 2. get index of product in _item
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    // 3. get whole product
    var existingProduct = _items[existingProductIndex];
    // 4. remove the item lcoally
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    // 5. Creating custom exceptions and error handling

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw Exception('Could not delete Item');
    }
  }

  List<Product> get items {
    // Problem - if user jumps to another page and comes back , the filter will still be applied , hence not a good practice
    // if (_showFavouritesOnly)
    //   return _items.where((element) => element.isFavourite).toList();
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> toggleFavourite(String id) async {
    final url = Uri.parse(
        'https://shopappflutter-d8463-default-rtdb.firebaseio.com/userFavourites/$authUserId/$id.json?auth=$authToken');
    final indexProduct = _items.indexWhere((element) => element.id == id);
    final newProduct = _items[indexProduct];
    newProduct.isFavourite = !newProduct.isFavourite;
    //? Optimization Method
    try {
      await http.put(url, body: json.encode(newProduct.isFavourite));
    } catch (error) {
      newProduct.isFavourite = !newProduct.isFavourite;
      throw Exception();
    }
    notifyListeners();
  }
}
