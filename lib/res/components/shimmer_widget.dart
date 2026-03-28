import 'package:flutter/material.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  });

  // Centralized design tokens for the Shimmer Animation
  static const Color baseColor = Color(0xFFEEEEEE); // Softer light grey
  static const Color highlightColor = Color(0xFFFBFBFB); // Platinum white
  static const Duration defaultDuration = Duration(seconds: 2);
  static const Duration defaultInterval = Duration(milliseconds: 300);

  const ShimmerWidget.circular({
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: baseColor,
        shape: shapeBorder,
      ),
    );
  }
}
