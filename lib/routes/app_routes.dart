import 'package:flutter/material.dart';

import '../presentation/booking_screen/booking_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/main_container/main_container_screen.dart';
import '../presentation/bookings_list_screen/bookings_list_screen.dart';
import '../presentation/messages_screen/messages_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';

import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String mainContainer = '/main-container';
  static const String homeScreen = '/home-screen';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String bookingScreen = '/booking-screen';
  static const String bookingsListScreen = '/bookings-list-screen';
  static const String messagesScreen = '/messages-screen';
  static const String profileScreen = '/profile-screen';
  static const String notificationsScreen = '/notifications-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    mainContainer: (context) => const MainContainerScreen(),
    homeScreen: (context) => const HomeScreen(),
    signUpLoginScreen: (context) => const SignUpLoginScreen(),
    bookingScreen: (context) => const BookingScreen(),
    bookingsListScreen: (context) => const BookingsListScreen(),
    messagesScreen: (context) => const MessagesScreen(),
    profileScreen: (context) => const ProfileScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
  };
}
