import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    // good practice - to move logic to the provider class
    // listen - false , dont want to rebuild widget or listen to the updates
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title,
                  style: TextStyle(
                    color: Colors.white70,
                  )),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            Text(
              '\$${loadedProduct.price.toString()}',
              style: TextStyle(
                fontSize: 30,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(height: 900)
          ]))
        ],
      ),
    );
  }
}
