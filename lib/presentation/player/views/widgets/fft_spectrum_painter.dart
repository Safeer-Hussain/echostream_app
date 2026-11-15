import 'package:flutter/material.dart';

class FftSpectrumPainter extends CustomPainter {
  final List<double> bands;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;

  FftSpectrumPainter({
    required this.bands,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bands.isEmpty) return;

    final bgPaint = Paint()..color = backgroundColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12.0),
    );
    canvas.drawRRect(rrect, bgPaint);

    final count = bands.length;
    final totalSpacing = (count - 1) * 2.0;
    final barWidth = (size.width - totalSpacing - 16.0) / count;

    for (int i = 0; i < count; i++) {
      final value = bands[i].clamp(0.04, 1.0);
      final barHeight = (size.height - 16.0) * value;
      final x = 8.0 + i * (barWidth + 2.0);
      final y = size.height - 8.0 - barHeight;

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [primaryColor.withOpacity(0.85), secondaryColor],
      );

      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final barPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2.5)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FftSpectrumPainter oldDelegate) {
    return oldDelegate.bands != bands ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
