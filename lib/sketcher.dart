import 'package:flutter/material.dart';
import 'package:flutter_parkinson/drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({required this.lines});

  // Method to draw on the canvas
  // All the drawing and painting logic
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }
  }

  // Optimization method that’s called whenever you create a new CustomPaint.
  // If the new instance represents different information than the old one, the method returns true.
  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
