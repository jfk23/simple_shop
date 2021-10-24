import 'package:flutter/material.dart';
import '../widget/app_drawer.dart';
import '../widget/product_grid.dart';
import '../providers/cart.dart';
import '../widget/badge.dart';
import 'package:provider/provider.dart';
import '../screen/cart_screen.dart';
import '../providers/products.dart';

enum ViewOption {
  Favorite,
  ShowAll,
}

class ProductOverview extends StatefulWidget {
  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  bool favSelected = false;
  var isInit = true;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Cart>(context, listen: false).fetchCartItem();
    });
  }

  @override
  void didChangeDependencies() {
    setState(() {
      isLoading = true;
    });

    if (isInit) {
      Provider.of<Products>(context, listen: false).fetchItems().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              //print(value);
              setState(() {
                if (value == ViewOption.Favorite) {
                  favSelected = true;
                } else {
                  favSelected = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Favorites'),
                value: ViewOption.Favorite,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: ViewOption.ShowAll,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, child) {
              return Badge(
                child: child,
                value: cart == null? 0 : cart.itemsCount.toString(),
              );
            },
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGridView(favSelected),
    );
  }
}
