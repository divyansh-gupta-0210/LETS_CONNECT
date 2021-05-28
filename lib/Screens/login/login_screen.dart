import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_connect/Screens/login/cubit/login_cubit.dart';
import 'package:lets_connect/Screens/signup/signup_screen.dart';
import 'package:lets_connect/repositories/auth/auth_repository.dart';
import 'package:lets_connect/widgets/error_dialog.dart';

class LoginScreen extends StatelessWidget {
  // LoginScreen({Key key}) : super(key: key);
  static const String routeName = '/login';

  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (context, _, __) => BlocProvider<LoginCubit>(
        create: (_) =>
            LoginCubit(authRepository: context.read<AuthRepository>()),
        child: LoginScreen(),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.error) {
              showDialog(
                  context: context,
                  builder: (context) =>
                      ErrorDialog(content: state.failure.message));
            }
          },
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple, Colors.orange],
                ),
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    // CustomPaint(painter: BackgroundPainter()),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.orange, Colors.purple])),
                          child: Card(
                            elevation: 10,
                            borderOnForeground: true,
                            color: Colors.white.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Lets Connect',
                                      style: TextStyle(
                                        fontSize: 28.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      cursorColor: Colors.deepOrange,
                                      cursorHeight: 25,
                                      cursorRadius: Radius.circular(10),
                                      style: TextStyle(fontSize: 17),
                                      decoration: InputDecoration(
                                          hintText: 'E-mail',
                                          hoverColor: Colors.deepOrange),
                                      onChanged: (value) => context
                                          .read<LoginCubit>()
                                          .emailChanged(value),
                                      validator: (value) => !value.contains('@')
                                          ? 'Please Enter a valid email'
                                          : null,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      cursorColor: Colors.black,
                                      cursorHeight: 25,
                                      cursorRadius: Radius.circular(10),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                      ),
                                      obscureText: true,
                                      onChanged: (value) => context
                                          .read<LoginCubit>()
                                          .passwordChanged(value),
                                      validator: (value) => value.length < 6
                                          ? 'Atleast 6 characters'
                                          : null,
                                    ),
                                    const SizedBox(
                                      height: 28,
                                    ),
                                    OutlineButton.icon(
                                      label: Text(
                                        'Sign In With Mail',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19),
                                      ),
                                      shape: StadiumBorder(),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      highlightedBorderColor: Colors.black,
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      textColor: Colors.black87,
                                      icon: Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.mail,
                                          size: 30,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () => _submitForm(
                                          context,
                                          state.status ==
                                              LoginStatus.submitting),
                                    ),
                                    const SizedBox(
                                      height: 17,
                                    ),
                                    OutlineButton.icon(
                                        label: Text(
                                          'No Account? Sign up',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 19),
                                        ),
                                        shape: StadiumBorder(),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        highlightedBorderColor: Colors.black,
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        textColor: Colors.black87,
                                        icon: Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            Icons.login,
                                            size: 30,
                                            color: Colors.red,
                                          ),
                                        ),
                                        onPressed: () => Navigator.of(context)
                                            .pushNamed(SignUpScreen.routeName)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState.validate() && !isSubmitting) {
      context.read<LoginCubit>().logInInWithCredentials();
    }
  }
}
