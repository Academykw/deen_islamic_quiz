import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/app_colors.dart';
import '../../core/widgets/coin_badge.dart';
import '../../core/widgets/geo_background.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/user_repository.dart';
import '../../state/auth_provider.dart';
import '../../state/coin_provider.dart';
import '../../app/router.dart';
import 'widgets/achievement_badge.dart';
import 'widgets/avatar_picker.dart';
import 'widgets/country_picker.dart';
import 'widgets/stat_grid.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl =
        TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    await UserRepository.instance.updateProfile(
      uid: uid,
      displayName: name,
    );

    setState(() => _isEditingName = false);
  }

  Future<void> _updateAvatar(String emoji) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await UserRepository.instance.updateProfile(
      uid: uid,
      avatarEmoji: emoji,
    );
  }

  Future<void> _updateCountry(String country) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    await UserRepository.instance.updateProfile(
      uid: uid,
      country: country,
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Sign Out?',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'You will be returned to the login screen.',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.wrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(currentUserProvider.notifier).signOut();
      await ref.read(coinProvider.notifier).resetCoins();
      if (mounted) context.goNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final coins = ref.watch(coinProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            backgroundColor: AppColors.dark,
            body: Center(
                child: Text('Not logged in',
                    style: TextStyle(color: Colors.white))),
          );
        }

        final achievements = buildAchievements(
          stagesCompleted: user.stagesCompleted,
          totalCorrect: user.totalCorrect,
          bestStreak: user.bestStreak,
          coins: coins,
        );

        final unlockedCount = achievements.where((a) => a.isUnlocked).length;

        return Scaffold(
          backgroundColor: AppColors.dark,
          body: Stack(
            children: [
              const GeoBackground(),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // ── App bar ───────────────────────
                    SliverToBoxAdapter(
                      child: _ProfileAppBar(
                        onSignOut: _signOut,
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── Avatar section ────────────
                          _AvatarSection(
                            user: user,
                            isEditingName: _isEditingName,
                            nameCtrl: _nameCtrl,
                            onAvatarTap: () => showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.transparent,
                              isScrollControlled: true,
                              builder: (_) => AvatarPicker(
                                currentEmoji: user.avatarEmoji,
                                onSelected: _updateAvatar,
                              ),
                            ),
                            onEditName: () =>
                                setState(() => _isEditingName = true),
                            onSaveName: _saveDisplayName,
                            onCancelEdit: () =>
                                setState(() => _isEditingName = false),
                            onCountryTap: () => showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.transparent,
                              isScrollControlled: true,
                              builder: (_) => CountryPicker(
                                currentCountry: user.country,
                                onSelected: _updateCountry,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Guest upgrade banner ──────
                          if (user.isGuest)
                            _GuestBanner(
                              onUpgrade: () =>
                                  context.goNamed(Routes.register),
                            ),

                          if (user.isGuest) const SizedBox(height: 16),

                          // ── Section: Stats ────────────
                          const _SectionLabel(text: 'YOUR STATS'),
                          const SizedBox(height: 12),

                          ProfileStatGrid(
                            totalCorrect: user.totalCorrect,
                            accuracy: user.accuracy,
                            bestStreak: user.bestStreak,
                            stagesCompleted: user.stagesCompleted,
                            coins: coins,
                            totalAttempted: user.totalAttempted,
                          ),

                          const SizedBox(height: 24),

                          // ── Section: Achievements ─────
                          Row(
                            children: [
                              const _SectionLabel(text: 'ACHIEVEMENTS'),
                              const Spacer(),
                              Text(
                                '$unlockedCount / ${achievements.length}',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Achievement grid
                          SizedBox(
                            height: 200,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: achievements.length,
                              itemBuilder: (_, i) => AchievementBadge(
                                achievement: achievements[i],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Sign out ──────────────────
                          GoldButton(
                            label: 'Sign Out',
                            onTap: _signOut,
                            variant: GoldButtonVariant.outlined,
                            icon: Icons.logout_rounded,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Profile app bar ────────────────────────────
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'الملف الشخصي',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
          ),
          const CoinBadge(size: CoinBadgeSize.small),
        ],
      ),
    );
  }
}

// ── Avatar section ─────────────────────────────
class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.user,
    required this.isEditingName,
    required this.nameCtrl,
    required this.onAvatarTap,
    required this.onEditName,
    required this.onSaveName,
    required this.onCancelEdit,
    required this.onCountryTap,
  });

  final AppUser user;
  final bool isEditingName;
  final TextEditingController nameCtrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;
  final VoidCallback onCancelEdit;
  final VoidCallback onCountryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: AppColors.gold, width: 2),
          left: BorderSide(color: AppColors.darkBorder),
          right: BorderSide(color: AppColors.darkBorder),
          bottom: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.1),
                    border: Border.all(
                        color: AppColors.gold, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.avatarEmoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.darkCard,
                          width: 2),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.dark,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Display name
          if (isEditingName)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkPanel,
                      contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.gold),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.gold,
                            width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.darkBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSaveName,
                  icon: const Icon(Icons.check_rounded,
                      color: AppColors.emeraldLight),
                ),
                IconButton(
                  onPressed: onCancelEdit,
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.wrong),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: onEditName,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.edit_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // Email
          Text(
            user.isGuest ? 'Guest Account' : user.email,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 10),

          // Country selector
          GestureDetector(
            onTap: onCountryTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.darkPanel,
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.public_rounded,
                      color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    user.country.isEmpty
                        ? 'Set your country'
                        : user.country,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      color: user.country.isEmpty
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded,
                      color: AppColors.textMuted, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest upgrade banner ───────────────────────
class _GuestBanner extends StatelessWidget {
  const _GuestBanner({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpgrade,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.15),
              AppColors.darkCard,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest Account',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    'Create an account to save your progress and appear on the leaderboard.',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.gold, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}