
import 'package:flutter/material.dart';

class DashedLineComponent extends StatelessWidget {
  final Axis axis; 
  final double dashWidth;
  final double dashHeight;
  final Color color;

  const DashedLineComponent({
    Key? key,
    this.axis = Axis.horizontal,
    this.dashWidth = 5.0,
    this.dashHeight = 1.0,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        axis: axis,
        dashWidth: dashWidth,
        dashHeight: dashHeight,
        color: color,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Axis axis;
  final double dashWidth;
  final double dashHeight;
  final Color color;

  _DashedLinePainter({
    required this.axis,
    required this.dashWidth,
    required this.dashHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dashHeight;

    double dashSpace = dashWidth * 1.5;
    double startX = 0;
    double startY = 0;

    if (axis == Axis.horizontal) {
      while (startX < size.width) {
        canvas.drawLine(
            Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
        startX += dashWidth + dashSpace;
      }
    } else {
      while (startY < size.height) {
        canvas.drawLine(
            Offset(0, startY), Offset(0, startY + dashHeight), paint);
        startY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
