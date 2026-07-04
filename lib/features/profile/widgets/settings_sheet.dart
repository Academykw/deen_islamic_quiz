import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constant/app_colors.dart';
import '../../../state/settings_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Sound toggle
          _SettingRow(
            icon: settings.isSoundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            label: 'Sound Effects',
            value: settings.isSoundEnabled,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleSound(),
          ),

          const SizedBox(height: 10),

          // Haptics toggle
          _SettingRow(
            icon: Icons.vibration_rounded,
            label: 'Haptic Feedback',
            value: settings.isHapticsEnabled,
            onChanged: (_) => ref
                .read(settingsProvider.notifier)
                .toggleHaptics(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppColors.gold : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withOpacity(0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.darkBorder,
          ),
        ],
      ),
    );
  }
}