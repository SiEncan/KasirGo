import 'package:flutter/material.dart';

Path getZigZagPath(Size size) {
  Path path = Path();
  // Smaller zig-zag size
  double toothWidth = 10.0;
  double toothHeight = 6.0;

  // Calculate exact tooth width to fit perfectly
  int count = (size.width / toothWidth).ceil();
  double actualToothWidth = size.width / count;

  path.moveTo(0, toothHeight);

  // Top Zigzag (Spikes pointing up)
  for (int i = 0; i < count; i++) {
    double x = i * actualToothWidth;
    path.lineTo(x + actualToothWidth / 2, 0);
    path.lineTo(x + actualToothWidth, toothHeight);
  }

  // Right Side
  path.lineTo(size.width, size.height - toothHeight);

  // Bottom Zigzag (Spikes pointing down)
  for (int i = 0; i < count; i++) {
    double x = size.width - (i * actualToothWidth);
    path.lineTo(x - actualToothWidth / 2, size.height);
    path.lineTo(x - actualToothWidth, size.height - toothHeight);
  }

  // Left Side
  path.lineTo(0, toothHeight);

  path.close();
  return path;
}

class ZigZagShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = getZigZagPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.grey.shade300
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => getZigZagPath(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.black,
    this.dashWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
