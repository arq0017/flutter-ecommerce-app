import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static final String routeName = '/orders-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // more optimistic way to use FutureBuilder - good practice .
  Future _orderFuture;
  Future _getOrderFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _orderFuture = _getOrderFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //! when fetchSetOrder is called then notifylisteners to Orders will be rebuild .
    //! hence ordersData will be changed by calling build method again
    //! Therefore fetchAndSet data will be recalled - hence infinite loop
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ));
            else {
              if (snapshot.hasError) {
                return Center(child: Text('An error has occured !'));
              } else {
                return Consumer<Orders>(
                  builder: (context, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          }),
    );
  }
}
