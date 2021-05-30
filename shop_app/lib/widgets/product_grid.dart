import 'package:flutter/material.dart';
import './product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {
  bool isFavs;
  ProductGrid(this.isFavs); 
  @override
  Widget build(BuildContext context) {
    // we created an instance of products class
    final productsData = Provider.of<Products>(context);
    final favouritesProducts = productsData.items.where((element) => element.isFavourite).toList() ; 
    final loadedProducts = (isFavs) ? favouritesProducts : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedProducts[i],
        child: ProductItem(
            // loadedProducts[i].id,
            // loadedProducts[i].title,
            // loadedProducts[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // amount of coloumns displayed on screen
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        // spacing between columns
        crossAxisSpacing: 10,
        // space b/w rows
        mainAxisSpacing: 10,
      ),
    );
  }
}
