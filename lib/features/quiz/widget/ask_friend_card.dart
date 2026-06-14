import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';


class AskFriendCard extends StatefulWidget {
  const AskFriendCard({
    super.key,
    required this.hint,
    required this.confidence,
  });

  final String hint;
  final int confidence;

  @override
  State<AskFriendCard> createState() => _AskFriendCardState();
}

class _AskFriendCardState extends State<AskFriendCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.lifelineBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.lifelineBlue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.lifelineBlue
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people_rounded,
                      color: AppColors.lifelineBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Friend Says',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lifelineBlue,
                    ),
                  ),
                  const Spacer(),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lifelineBlue
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.confidence}% sure',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lifelineBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Hint text
              Text(
                widget.hint,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              // Confidence bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Confidence',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${widget.confidence}%',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lifelineBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.confidence / 100,
                      backgroundColor: AppColors.darkBorder,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.lifelineBlue),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
