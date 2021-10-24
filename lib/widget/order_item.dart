import 'package:flutter/material.dart';
import 'dart:math';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;
  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem>
    with SingleTickerProviderStateMixin {
  // Animation<Offset> _slideAnimation;
  // AnimationController _controller;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(
  //       vsync: this, duration: Duration(milliseconds: 300));
  //   _slideAnimation =
  //       Tween<Offset>(begin: Offset(0, 0), end: Offset(0, 0.25)).animate(
  //     CurvedAnimation(parent: _controller, curve: Curves.easeIn),
  //   );
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _controller.dispose();
  // }

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded? min(widget.orderItem.productList.length * 20.0 + 150.0, 175) : 95,
          child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.orderItem.total.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat.yMMMMd().format(widget.orderItem.dateTime),
              ),
              trailing: IconButton(
                icon:
                    _expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
                onPressed: () {
                  // print('pressed');
                  // if (_expanded) {
                  //   _controller.reverse();
                    
                  // } else {
                  //   _controller.forward();
                  // }
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeIn,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                // constraints: BoxConstraints(
                //     minHeight: widget.orderItem.productList.length * 20.0 + 20.0,
                //     maxHeight: 100),
                height: _expanded? 
                    min(widget.orderItem.productList.length * 20.0 + 20.0, 100): 0,
                child: ListView(
                  children: widget.orderItem.productList
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${prod.title}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${prod.quantity}X \$${prod.price}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
