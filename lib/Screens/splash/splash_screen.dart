import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_connect/Screens/login/login_screen.dart';
import 'package:lets_connect/Screens/nav/nav_screen.dart';
import 'package:lets_connect/blocs/blocs.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key key}) : super(key: key);
  static const String routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prevState, state) => prevState.status != state.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            // go to login screen
            Navigator.of(context).pushNamed(LoginScreen.routeName);
          } else if (state.status == AuthStatus.authenticated) {
            //go to nav screen
            Navigator.of(context).pushNamed(NavScreen.routeName);
          }
        },
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
