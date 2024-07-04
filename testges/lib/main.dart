import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service/authentication_provider.dart';
import 'page/login_page.dart';
import 'page/home_screen.dart';


void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeSign',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        colorScheme: ColorScheme(
          primary: Colors.yellow,
          primaryContainer: Colors.yellow[700]!,
          secondary: Colors.orange,
          secondaryContainer: Colors.orange[700]!,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);

    if (authState != null) {
      return HomeScreen();
    } else {
      return LoginPage();
    }
  }
}
