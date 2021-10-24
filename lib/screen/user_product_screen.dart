import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widget/user_product_item.dart';
import '../widget/app_drawer.dart';
import './product_edit_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> updateProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchItems(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(ProductEditScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: updateProduct(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => updateProduct(context),
                    child: Consumer<Products>(
                      builder: (context, productData, _) => ListView.builder(
                        itemBuilder: (ctx, index) => Column(
                          children: <Widget>[
                            UserProductItem(
                              productData.items[index].id,
                              productData.items[index].title,
                              productData.items[index].imageUrl,
                            ),
                            Divider(),
                          ],
                        ),
                        itemCount: productData.items.length,
                      ),
                    ),
                  ),
      ),
    );
  }
}
