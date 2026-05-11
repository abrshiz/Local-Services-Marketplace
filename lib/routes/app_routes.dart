import 'package:flutter/material.dart';

import '../presentation/booking_screen/booking_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String bookingScreen = '/booking-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SignUpLoginScreen(),
    homeScreen: (context) => const HomeScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    bookingScreen: (context) => const BookingScreen(),
  };
}
