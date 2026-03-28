import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:travel_planner/res/components/shimmer_widget.dart';

class ShimmerImage extends StatefulWidget {
  final String imageUrl;
  final String fallbackText;
  final double? width;
  final double? height;
  final double borderRadius;
  final int timeoutSeconds;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    this.width,
    this.height,
    this.borderRadius = 15,
    this.timeoutSeconds = 5,
  });

  @override
  State<ShimmerImage> createState() => _ShimmerImageState();
}

class _ShimmerImageState extends State<ShimmerImage> {
  bool _isTimeout = false;
  bool _isLoaded = false;
  bool _isError = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: widget.timeoutSeconds), () {
      if (mounted && !_isLoaded) {
        setState(() {
          _isTimeout = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTimeout || _isError) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            // Image is fully loaded
            // We can't call setState here, but we can use a post frame callback
            // to clear the timer if it hasn't fired yet.
            if (!_isLoaded) {
              _isLoaded = true;
              _timer?.cancel();
            }
            return child;
          }
          // Image is still loading
          return _buildShimmer();
        },
        errorBuilder: (context, error, stackTrace) {
          // If loading fails, show fallback
          return _buildFallback();
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer(
      duration: ShimmerWidget.defaultDuration,
      interval: ShimmerWidget.defaultInterval,
      color: ShimmerWidget.highlightColor,
      colorOpacity: 0.3,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: ShimmerWidget.rectangular(
        height: widget.height ?? double.infinity,
        width: widget.width ?? double.infinity,
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.fallbackText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
