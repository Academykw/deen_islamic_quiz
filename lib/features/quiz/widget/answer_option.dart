import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

enum AnswerState { idle, selected, correct, wrong }

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.state,
    required this.onTap,
  });

  final String label;
  final int index;
  final AnswerState state;
  final VoidCallback? onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  Color get _borderColor {
    switch (state) {
      case AnswerState.idle:     return AppColors.darkBorder;
      case AnswerState.selected: return AppColors.gold;
      case AnswerState.correct:  return AppColors.correct;
      case AnswerState.wrong:    return AppColors.wrong;
    }
  }

  Color get _bgColor {
    switch (state) {
      case AnswerState.idle:
        return AppColors.darkCard;
      case AnswerState.selected:
        return AppColors.gold.withOpacity(0.08);
      case AnswerState.correct:
        return AppColors.correct.withOpacity(0.12);
      case AnswerState.wrong:
        return AppColors.wrong.withOpacity(0.12);
    }
  }

  Color get _letterBg {
    switch (state) {
      case AnswerState.idle:     return AppColors.darkPanel;
      case AnswerState.selected: return AppColors.gold.withOpacity(0.2);
      case AnswerState.correct:  return AppColors.correct.withOpacity(0.2);
      case AnswerState.wrong:    return AppColors.wrong.withOpacity(0.2);
    }
  }

  Color get _textColor {
    switch (state) {
      case AnswerState.idle:     return AppColors.textPrimary;
      case AnswerState.selected: return AppColors.gold;
      case AnswerState.correct:  return AppColors.correct;
      case AnswerState.wrong:    return AppColors.wrong;
    }
  }

  IconData? get _trailingIcon {
    switch (state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
          width: state == AnswerState.idle ? 1 : 1.5,
        ),
        boxShadow: state != AnswerState.idle
            ? [
          BoxShadow(
            color: _borderColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: state == AnswerState.idle ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.gold.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Letter badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _letterBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _letters[index],
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Answer text
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: state == AnswerState.idle
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: _textColor,
                      height: 1.4,
                    ),
                  ),
                ),

                // Trailing icon
                if (_trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    _trailingIcon,
                    color: _borderColor,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}