import 'package:flutter/material.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 16,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
