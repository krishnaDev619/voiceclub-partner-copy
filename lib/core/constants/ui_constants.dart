import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class ApplicationColors {
  static const primaryRed = Color(0xFFEE6464);
  static const lightAstro = Color(0xFFFFE8BE);
  static const errorColor = Colors.red;
  static const grey = Color(0xFFB3B3B3);
  static const iconGrey = Color(0xFF525252);
  static const primaryColorDark = Color(0xFFFF6666);
  static const green = Color(0xFF33FE91);
  static const textGreen = Color(0xFF00B664);
  static const black = Color(0xFF000000);
  static const lightGrey = Color(0xFF36363B);
  static const textGrey = Color(0xFFB6B6BA);
  static const textGreyDark = Color(0xFF686868);
  static const fillWhite = Color(0xFFF8F7FE);
  static const scaffoldLight = Color(0xFFFFF6DE);
  static const scaffoldDark = Color(0xFF252529);
  static const gossip = Color(0xFFEE6464);
  static const astro = Color(0xFFFFC947);
  static const love = Color(0xFFAF45D4);
  static const blue = Color(0xFF0E9BC8);
  static const yellow = Color(0xFFFFC267);
  static const screenBackground = Color(0xFFF9F9F9);
  static const white = Colors.white;
  static const lightRed = Color(0xFFFFEDED);
  static const lightYellow = Color(0xFFFFF0DA);
}

class FontSize {
  static const double xS = 9.0;
  static const double S = 10.0;
  static const double M = 12.0;
  static const double L = 14.0;
  static const double xL = 16.0;
  static const double xXL = 18.0;
  static const double xXXL = 20.0;
  static const double xXXXL = 28.0;
}

class Weight {
  static const FontWeight light = FontWeight.w200;
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight heavy = FontWeight.w600;
  static const FontWeight bold = FontWeight.w800;
}

class TextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: FontSize.xXXXL,
    fontWeight: Weight.bold,
    color: ApplicationColors.black,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: FontSize.xXXL,
    fontWeight: Weight.heavy,
    color: ApplicationColors.black,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: FontSize.M,
    fontWeight: Weight.heavy,
    color: Colors.white,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: FontSize.xL,
    fontWeight: Weight.bold,
    color: ApplicationColors.black,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: FontSize.L,
    fontWeight: Weight.heavy,
    color: Colors.white,
  );
  static const TextStyle bodyText = TextStyle(
    fontSize: FontSize.M,
    fontWeight: Weight.normal,
    color: ApplicationColors.black,
  );
  static TextStyle smallText = const TextStyle(
    fontSize: FontSize.S,
    fontWeight: Weight.normal,
    color: Colors.white,
  );
}

class ShimmerCustom extends StatelessWidget {
  final Widget child;

  const ShimmerCustom({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}

class Gradients {
  static LinearGradient yellowGradient({bool fromTopToBottom = false}) {
    return LinearGradient(
      begin: fromTopToBottom ? Alignment.topCenter : Alignment.centerLeft,
      end: fromTopToBottom ? Alignment.bottomCenter : Alignment.centerRight,
      colors: const [
        Color(0xFFF9C564),
        Color(0xFFDFBA74),
        Color(0xFFFCE7C3),
        Color(0xFFDDB262),
        Color(0xFFBC9855),
      ],
    );
  }

  static LinearGradient primaryGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFFF7777), Color(0xFFFF9B6D)],
    );
  }

  static LinearGradient textGrey() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF686868), Color(0xFF686868)],
    );
  }

  static LinearGradient textYellow() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFF4C430), Color(0xFFF4C430)],
    );
  }

  static LinearGradient textBlack() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.black, Colors.black],
    );
  }

  static LinearGradient borderGrey() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFDFDFDF), Color(0xFFDFDFDF)],
    );
  }
}

const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.white,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
);

class NoSplashScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsets margin;

  const ShimmerContainer({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 0.0,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerCustom(
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class MetricsUIConstants {
  static const Color yellowColor = Color(0xFFFAB431);
  static const Color greenColor = Color(0xFF188538);
  static const Color redColor = Color(0xFFE46962);
}
