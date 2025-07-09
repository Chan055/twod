import 'package:flutter/material.dart';

class CardComponents {
  static Container GetCard({
    required time,
    required number,
  }) {
    return Container(
      width: 107,
      height: 77,
      decoration: BoxDecoration(
        color: Color(0xFF5B9547),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 3,
          ),
          Text(time, style: const TextStyle(fontSize: 18)),
          SizedBox(
            width: 100,
            height: 5,
            child: CustomPaint(
              painter: HorizontalLinePainter(),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Text("${number ?? '??'}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

class HorizontalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2B2D42)
      ..strokeWidth = 1.5;

    final start = Offset(0, size.height / 2); // Start from left middle
    final end = Offset(size.width, size.height / 2); // End at right middle

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
