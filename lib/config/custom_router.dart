import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_connect/Screens/comments/comments.dart';
import 'package:lets_connect/Screens/screens.dart';

class CustomRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    print('Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const Scaffold(),
        );

      case SplashScreen.routeName:
        return SplashScreen.route();

      case LoginScreen.routeName:
        return LoginScreen.route();

      case SignUpScreen.routeName:
        return SignUpScreen.route();

      case NavScreen.routeName:
        return NavScreen.route();

      default:
        return _errorRoute();
    }
  }

  static Route onGenerateNestedRoute(RouteSettings settings) {
    print('Nested Route: ${settings.name}');
    switch (settings.name) {
      case ProfileScreen.routeName:
        return ProfileScreen.route(args: settings.arguments);
      case EditProfileScreen.routeName:
        return EditProfileScreen.route(args: settings.arguments);
      case CommentsScreen.routeName:
        return CommentsScreen.route(args: settings.arguments);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text("Something went wrong!"),
        ),
      ),
    );
  }
}
