import 'package:flutter/material.dart';

class CardComponents {
  static Container GetCard({
    required String time,
    required String number,
    double width = double.infinity,
    double height = 77,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF5B9547),
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            width: width * 0.9, // line width relative to container width
            height: 5,
            child: CustomPaint(
              painter: HorizontalLinePainter(),
            ),
          ),
          Text(
            number.isNotEmpty ? number.padLeft(2, '0') : '??',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class HorizontalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..strokeWidth = 1.5;

    final start = Offset(0, size.height / 2); // Start from left middle
    final end = Offset(size.width, size.height / 2); // End at right middle

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
