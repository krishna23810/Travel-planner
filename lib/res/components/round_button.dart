import 'package:flutter/material.dart';
import '../colors.dart';
import 'shimmer_widget.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final bool isLoading;
  final double height;
  final double width;
  const RoundButton({
    Key? key,
    required this.title,
    required this.onPress,
    this.isLoading = false,
    this.height = 40,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isLoading
              ? ShimmerWidget.rectangular(
                  height: height * 0.5,
                  width: width * 0.7,
                )
              : Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
