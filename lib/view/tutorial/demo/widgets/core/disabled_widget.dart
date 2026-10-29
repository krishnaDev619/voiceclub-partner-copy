import 'package:flutter/material.dart';

class Disabled extends StatelessWidget {
  final Widget child;
  final bool disabled;
  final double opacity;

  const Disabled({
    super.key,
    required this.child,
    this.opacity = 0.25,
    this.disabled = true,
  });

  static const ColorFilter greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, // R
    0.2126, 0.7152, 0.0722, 0, 0, // G
    0.2126, 0.7152, 0.0722, 0, 0, // B
    0, 0, 0, 1, 0, // A
  ]);

  static const ColorFilter greyscaleLighter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0.1, // Add a bias of 0.1 to R
    0.2126, 0.7152, 0.0722, 0, 0.1, // Add a bias of 0.1 to G
    0.2126, 0.7152, 0.0722, 0, 0.1, // Add a bias of 0.1 to B
    0, 0, 0, 1, 0, // Keep alpha unchanged
  ]);

  static const ColorFilter noEffect = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0, // Red channel remains unchanged
    0, 1, 0, 0, 0, // Green channel remains unchanged
    0, 0, 1, 0, 0, // Blue channel remains unchanged
    0, 0, 0, 1, 0, // Alpha channel remains unchanged
  ]);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: Opacity(
        opacity: disabled ? opacity : 1.0,
        child: ColorFiltered(
          colorFilter: disabled ? greyscale : noEffect,
          child: child,
        ),
      ),
    );
  }
}
