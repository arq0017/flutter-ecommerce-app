import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    /*
          * * on Refresh function accepts future <void> type function 
          * * Automatically loads spinner but need to stop it , hence asks for method 
          */
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, child) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (ctx, index) => UserProductItem(
                                id: productsData.items[index].id,
                                title: productsData.items[index].title,
                                imageURL: productsData.items[index].imageUrl)),
                      ),
                    ),
                  ),
      ),
    );
  }
}
