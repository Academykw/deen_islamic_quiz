import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';


class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    required this.currentEmoji,
    required this.onSelected,
  });

  final String currentEmoji;
  final ValueChanged<String> onSelected;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  static const _avatars = [
    '🕌', '☪️', '📖', '🌙', '⭐', '🕋',
    '🤲', '🌿', '🦁', '🐉', '🦅', '🌊',
    '🔥', '⚡', '💎', '🏆', '🎯', '🧠',
    '👑', '🌺', '🌸', '🍃', '🌴', '🦋',
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Choose Avatar',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Current selection preview
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.1),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Center(
              child: Text(
                _selected,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _avatars.length,
            itemBuilder: (_, i) {
              final emoji = _avatars[i];
              final isSelected = emoji == _selected;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selected = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withOpacity(0.15)
                        : AppColors.darkPanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : AppColors.darkBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.goldGlow,
                    AppColors.gold,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    widget.onSelected(_selected);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const Center(
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}