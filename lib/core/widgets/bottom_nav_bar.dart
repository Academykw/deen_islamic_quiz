import 'package:flutter/material.dart';

import '../constant/app_colors.dart';

class DeenBottomNavBar extends StatelessWidget {
  const DeenBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.emoji_events_rounded, label: 'Ranks'),
    (icon: Icons.person_rounded, label: 'Profile'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.darkPanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(7),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavItem(
                  icon: _items[index].icon,
                  label: _items[index].label,
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isActive,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold.withValues(alpha: 0.13)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.goldLight : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.goldLight : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
