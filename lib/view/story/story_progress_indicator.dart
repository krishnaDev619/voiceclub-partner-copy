import 'package:flutter/material.dart';

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final Animation<double>? animation;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;

  const PageBar(
    this.animation, {
    this.indicatorColor,
    this.indicatorForegroundColor,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: StoryProgressIndicator(
        widget.animation!.value,
        indicatorHeight: 5,
        indicatorColor: widget.indicatorColor,
        indicatorForegroundColor: widget.indicatorForegroundColor,
      ),
    );
  }
}

class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;

  const StoryProgressIndicator(
    this.value, {
    super.key,
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(indicatorHeight),
      foregroundPainter: IndicatorOval(
        indicatorForegroundColor ?? Colors.white.withValues(alpha: 0.8),
        value,
      ),
      painter: IndicatorOval(
        indicatorColor ?? Colors.white.withValues(alpha: 0.4),
        1.0,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorOval(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * widthFactor, size.height),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
