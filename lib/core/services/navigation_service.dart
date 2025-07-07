import 'package:flutter/material.dart';
import '../widgets/page_transition.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<dynamic> navigateTo(
    Widget page, {
    PageTransitionType transition = PageTransitionType.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return navigator!.push(
      AppPageTransition(page: page, type: transition, duration: duration),
    );
  }

  Future<dynamic> navigateToReplacement(
    Widget page, {
    PageTransitionType transition = PageTransitionType.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return navigator!.pushReplacement(
      AppPageTransition(page: page, type: transition, duration: duration),
    );
  }

  Future<dynamic> navigateToAndRemoveUntil(
    Widget page, {
    bool Function(Route<dynamic>)? predicate,
    PageTransitionType transition = PageTransitionType.rightToLeft,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return navigator!.pushAndRemoveUntil(
      AppPageTransition(page: page, type: transition, duration: duration),
      predicate ?? (_) => false,
    );
  }

  void goBack([dynamic result]) {
    if (navigator!.canPop()) {
      navigator!.pop(result);
    }
  }

  void popUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
  }
}
