import 'package:flutter/material.dart';
import './screen/order_screen.dart';
import './screen/splash_screen.dart';
import './screen/product_overview_screen.dart';
import './screen/product_detail_screen.dart';
import './screen/cart_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screen/user_product_screen.dart';
import './screen/product_edit_screen.dart';
import './screen/auth_screen.dart';
import './providers/auth.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, auth, previousProduct) => Products(
              auth.token,
              auth.userId,
              previousProduct == null ? [] : previousProduct.items),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Cart>(
          update: (context, auth, previousCart) => Cart(auth.token, auth.userId,
              previousCart == null ? {} : previousCart.items),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrder) => Orders(auth.token,
              auth.userId, previousOrder == null ? [] : previousOrder.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.orange,
            fontFamily: 'Lato',
            pageTransitionsTheme: CustomPageTransition(),
          ),
          home: authData.isAuth
              ? ProductOverview()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            ProductEditScreen.routeName: (ctx) => ProductEditScreen(),
          },
        ),
      ),
    );
  }
}
