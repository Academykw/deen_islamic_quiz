import 'package:flutter/material.dart';
import '../constant/app_colors.dart';


class NoorCard extends StatelessWidget {
  const NoorCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.topBorderColor = AppColors.gold,
    this.showTopBorder = true,
    this.borderRadius = 20,
    this.backgroundColor,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color topBorderColor;
  final bool showTopBorder;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.darkCard;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border(
          top: showTopBorder
              ? BorderSide(color: topBorderColor, width: 2)
              : BorderSide.none,
          left: const BorderSide(color: AppColors.darkBorder, width: 1),
          right: const BorderSide(color: AppColors.darkBorder, width: 1),
          bottom: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: AppColors.transparent,
          child: onTap != null
              ? InkWell(
            onTap: onTap,
            splashColor: topBorderColor.withOpacity(0.08),
            child: Padding(padding: padding, child: child),
          )
              : Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}