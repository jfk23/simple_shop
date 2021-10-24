import 'package:flutter/material.dart';

class CustomeRoute<T> extends MaterialPageRoute<T> {
  CustomeRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    // RouteSettings settings,
    //Route route,
  ) {
    if (settings.name == '/') {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransition extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    {
      if (route.settings.name == '/') {
        return child;
      }

      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }
  }
}
