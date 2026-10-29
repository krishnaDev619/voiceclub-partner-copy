import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.size,
    required this.iconSrc,
    this.color = Colors.white,
    this.iconColor = Colors.black,
    required this.press,
    this.iconData,
  });

  final double size;
  final String iconSrc;
  final Color color, iconColor;
  final VoidCallback press;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(15 / 64 * size),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          foregroundColor: color,
          backgroundColor: color,
        ),
        onPressed: press,
        child:
            iconData != null
                ? Icon(iconData, color: iconColor)
                : SvgPicture.asset(
                  iconSrc,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
      ),
    );
  }
}

class RectangleButton extends StatelessWidget {
  const RectangleButton({
    super.key,
    this.size = 64,
    required this.iconSrc,
    this.color = Colors.white,
    this.iconColor = Colors.black,
    required this.press,
  });

  final double size;
  final String iconSrc;
  final Color color, iconColor;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(15 / 64 * size),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          foregroundColor: color,
          backgroundColor: color,
        ),
        onPressed: press,
        child: SvgPicture.asset(iconSrc),
      ),
    );
  }
}
