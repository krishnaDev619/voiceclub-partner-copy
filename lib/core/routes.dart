import 'package:flutter/material.dart';
import 'package:voiceclub_partner/view/auth/splash_screen.dart';
import 'package:voiceclub_partner/view/social/view_post_screen.dart';
// Import other view files as needed

class RouteGenerator {
  // Route Names
  static const String defaultRoute = '/';
  static const String landingScreenRoute = '/landing';
  static const String loginScreenRoute = '/login';
  static const String registerScreenRoute = '/register';
  static const String otpScreenRoute = '/otp';
  static const String postScreenRoute = '/post';

  static const List<String> allRoutes = [postScreenRoute];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final params =
        (settings.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
    switch (settings.name) {
      case defaultRoute:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case postScreenRoute:
        final postId = params['postId'].toString();
        return MaterialPageRoute(
          builder: (context) => ViewPostScreen(postId: postId),
        );
      default:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
    }
  }
}
