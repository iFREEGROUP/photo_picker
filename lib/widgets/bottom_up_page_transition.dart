import 'package:flutter/material.dart';

class BottomUpPageRoute<T> extends PageRoute<T> {
  BottomUpPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.transitionCurve = Curves.easeIn,
    this.transitionDuration = const Duration(milliseconds: 300),
  }) : super(settings: settings);

  final Widget builder;

  final Curve transitionCurve;

  @override
  final Duration transitionDuration;

  @override
  final bool opaque = true;

  @override
  final bool barrierDismissible = false;

  @override
  final bool maintainState = true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(curve: transitionCurve, parent: animation),
      ),
      child: child,
    );
  }
}
