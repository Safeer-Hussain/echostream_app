import 'package:flutter/material.dart';

class FrequencyCurvePainter extends CustomPainter {
  final List<double> bands; // 10 bands -12.0 to +12.0
  final Color curveColor;
  final Color fillColor;
  final Color gridColor;

  FrequencyCurvePainter({
    required this.bands,
    required this.curveColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bands.isEmpty) return;

    // Draw reference grid lines: +12dB, 0dB, -12dB
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    // 0dB baseline
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), gridPaint);
    // +6dB and -6dB dashed/subtle lines
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.25),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      gridPaint,
    );

    final points = <Offset>[];
    final count = bands.length;
    final stepX = size.width / (count - 1);

    for (int i = 0; i < count; i++) {
      final gain = bands[i]; // -12.0 to +12.0
      // Normalize to 0.0 (top=+12dB) to 1.0 (bottom=-12dB)
      final normY = 0.5 - (gain / 24.0);
      final x = i * stepX;
      final y = (normY * size.height).clamp(4.0, size.height - 4.0);
      points.add(Offset(x, y));
    }

    // Build smooth cubic Bezier path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill underneath the curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor.withOpacity(0.35), fillColor.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw main curve
    final curvePaint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, curvePaint);

    // Draw dots at control points
    final dotPaint = Paint()
      ..color = curveColor
      ..style = PaintingStyle.fill;
    for (final pt in points) {
      canvas.drawCircle(pt, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FrequencyCurvePainter oldDelegate) {
    return oldDelegate.bands != bands ||
        oldDelegate.curveColor != curveColor ||
        oldDelegate.fillColor != fillColor;
  }
}
