import 'package:flutter/material.dart';

import '../../core/constant/app_colors.dart';

enum LifelineType { fiftyFifty, askFriend, extraTime }

class Lifeline {
  const Lifeline({
    required this.type,
    required this.isUsed,
    this.isDisabled = false,
  });

  final LifelineType type;
  final bool isUsed;
  final bool isDisabled;

  String get label {
    switch (type) {
      case LifelineType.fiftyFifty: return '50/50';
      case LifelineType.askFriend:  return 'Ask Friend';
      case LifelineType.extraTime:  return '+15s';
    }
  }

  String get description {
    switch (type) {
      case LifelineType.fiftyFifty:
        return 'Remove 2 wrong answers';
      case LifelineType.askFriend:
        return 'See a hint with confidence';
      case LifelineType.extraTime:
        return 'Add 15 seconds to timer';
    }
  }

  IconData get icon {
    switch (type) {
      case LifelineType.fiftyFifty: return Icons.filter_2_rounded;
      case LifelineType.askFriend:  return Icons.people_rounded;
      case LifelineType.extraTime:  return Icons.timer_rounded;
    }
  }

  Color get color {
    switch (type) {
      case LifelineType.fiftyFifty: return AppColors.lifelineRed;
      case LifelineType.askFriend:  return AppColors.lifelineBlue;
      case LifelineType.extraTime:  return AppColors.lifelinePurple;
    }
  }

  int get coinCost {
    switch (type) {
      case LifelineType.fiftyFifty: return 50;
      case LifelineType.askFriend:  return 75;
      case LifelineType.extraTime:  return 30;
    }
  }

  Lifeline copyWith({bool? isUsed, bool? isDisabled}) {
    return Lifeline(
      type: type,
      isUsed: isUsed ?? this.isUsed,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}