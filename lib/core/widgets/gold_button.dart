import 'package:flutter/material.dart';

import '../constant/app_colors.dart';


enum GoldButtonVariant { filled, outlined, ghost }

class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = GoldButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onTap;
  final GoldButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool active = !isDisabled && !isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: AnimatedOpacity(
        opacity: active ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case GoldButtonVariant.filled:
        return _FilledGoldButton(
          label: label,
          icon: icon,
          isLoading: isLoading,
          onTap: isDisabled ? null : onTap,
        );
      case GoldButtonVariant.outlined:
        return _OutlinedGoldButton(
          label: label,
          icon: icon,
          onTap: isDisabled ? null : onTap,
        );
      case GoldButtonVariant.ghost:
        return _GhostGoldButton(
          label: label,
          icon: icon,
          onTap: isDisabled ? null : onTap,
        );
    }
  }
}

class _FilledGoldButton extends StatelessWidget {
  const _FilledGoldButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldGlow, AppColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.white.withOpacity(0.1),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.dark,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.dark, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedGoldButton extends StatelessWidget {
  const _OutlinedGoldButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.gold.withOpacity(0.1),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostGoldButton extends StatelessWidget {
  const _GhostGoldButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}