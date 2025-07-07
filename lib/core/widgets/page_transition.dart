import 'package:flutter/material.dart';

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
}

class AppPageTransition extends PageRouteBuilder {
  final Widget page;
  final PageTransitionType type;
  final Curve curve;
  final Alignment alignment;
  final Duration duration;

  AppPageTransition({
    required this.page,
    this.type = PageTransitionType.rightToLeft,
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           switch (type) {
             case PageTransitionType.fade:
               return FadeTransition(opacity: animation, child: child);
             case PageTransitionType.rightToLeft:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(1, 0),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: child,
               );
             case PageTransitionType.leftToRight:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(-1, 0),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: child,
               );
             case PageTransitionType.upToDown:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0, -1),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: child,
               );
             case PageTransitionType.downToUp:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0, 1),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: child,
               );
             case PageTransitionType.scale:
               return ScaleTransition(
                 alignment: alignment,
                 scale: CurvedAnimation(parent: animation, curve: curve),
                 child: child,
               );
             case PageTransitionType.rotate:
               return RotationTransition(
                 alignment: alignment,
                 turns: animation,
                 child: child,
               );
             case PageTransitionType.size:
               return Align(
                 alignment: alignment,
                 child: SizeTransition(
                   sizeFactor: animation,
                   axisAlignment: 0.0,
                   child: child,
                 ),
               );
             case PageTransitionType.rightToLeftWithFade:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(1, 0),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: FadeTransition(opacity: animation, child: child),
               );
             case PageTransitionType.leftToRightWithFade:
               return SlideTransition(
                 position: Tween<Offset>(
                   begin: const Offset(-1, 0),
                   end: Offset.zero,
                 ).animate(CurvedAnimation(parent: animation, curve: curve)),
                 child: FadeTransition(opacity: animation, child: child),
               );
           }
         },
       );
}

// Extension method for easier navigation
extension NavigatorExtension on BuildContext {
  Future<T?> pushPageTransition<T extends Object?>(
    Widget page, {
    PageTransitionType type = PageTransitionType.rightToLeft,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(this).push<T>(
      AppPageTransition(
            page: page,
            type: type,
            curve: curve,
            alignment: alignment,
            duration: duration,
          )
          as Route<T>,
    );
  }

  Future<T?>
  pushReplacementPageTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    PageTransitionType type = PageTransitionType.rightToLeft,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      AppPageTransition(
            page: page,
            type: type,
            curve: curve,
            alignment: alignment,
            duration: duration,
          )
          as Route<T>,
      result: result,
    );
  }

  Future<T?> pushAndRemoveUntilPageTransition<T extends Object?>(
    Widget page,
    bool Function(Route<dynamic>) predicate, {
    PageTransitionType type = PageTransitionType.rightToLeft,
    Curve curve = Curves.easeInOut,
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      AppPageTransition(
            page: page,
            type: type,
            curve: curve,
            alignment: alignment,
            duration: duration,
          )
          as Route<T>,
      predicate,
    );
  }
}
