import 'package:flutter/material.dart';
import 'package:shop_app/custom_page_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/manage_product_screen.dart';
import 'package:shop_app/widgets/splash_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/cart_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';
import './providers/cart.dart';
import './screens/orders_screen.dart';
import './providers/orders.dart' show Orders;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          // create initialize the instances and update updates them afterwards
          create: (_) => Products(null, null, []),
          update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders(null, null, []),
            update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders)),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Shop',
          theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.deepOrange,
              primaryColor: Colors.orange,
              accentColor: Colors.orange[400],
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBulder(),
                TargetPlatform.iOS: CustomPageTransitionBulder(),
              })),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
