import 'package:flutter/material.dart';
import 'splash.dart';
import 'sign_in.dart';
import 'home.dart';

void main() {
  runApp(MaterialApp(
    title: 'Pranzo',
    initialRoute: '/',
    routes: {
      '/': (context) => SplashScreen(),
      '/sign_in': (context) => SignInScreen(),
      '/home': (context) => HomeScreen(),
    },
  ));
}
