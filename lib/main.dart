import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_connect/blocs/auth/auth_bloc.dart';
import 'package:lets_connect/blocs/simple_bloc_observer.dart';
import 'package:lets_connect/config/custom_router.dart';
import 'package:lets_connect/Screens/screens.dart';
import 'package:lets_connect/cubits/cubits.dart';
import 'package:lets_connect/repositories/auth/auth_repository.dart';
import 'package:lets_connect/repositories/repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // context.read<AuthRepository>();
    AuthRepository().logout();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        RepositoryProvider<StorageRepository>(
          create: (_) => StorageRepository(),
        ),
        RepositoryProvider<PostRepository>(
          create: (_) => PostRepository(),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<LikedPostsCubit>(
            create: (context) => LikedPostsCubit(
              postRepository: context.read<PostRepository>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Lets Connect',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: AppBarTheme(
                brightness: Brightness.light,
                centerTitle: true,
                color: Colors.white,
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
                textTheme: const TextTheme(
                  headline6: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity),
          onGenerateRoute: CustomRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
