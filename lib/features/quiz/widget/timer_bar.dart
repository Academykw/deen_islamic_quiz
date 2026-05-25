import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({
    super.key,
    required this.seconds,
    required this.onTimeUp,
    required this.isPaused,
  });

  final int seconds;
  final VoidCallback onTimeUp;
  final bool isPaused;

  @override
  State<TimerBar> createState() => TimerBarState();
}

class TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Timer _ticker;
  late int _remaining;
  bool _called = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.isPaused) return;
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0 && !_called) {
        _called = true;
        _ctrl.stop();
        widget.onTimeUp();
      }
    });
  }

  /// Called by parent to add extra time (lifeline — Phase 2)
  void addTime(int extraSeconds) {
    setState(() {
      _remaining += extraSeconds;
      _called = false;
    });
  }

  @override
  void didUpdateWidget(TimerBar old) {
    super.didUpdateWidget(old);
    if (widget.isPaused && !old.isPaused) _ctrl.stop();
    if (!widget.isPaused && old.isPaused) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _ticker.cancel();
    super.dispose();
  }

  Color get _barColor {
    if (_remaining > 20) return AppColors.emeraldLight;
    if (_remaining > 10) return AppColors.gold;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_remaining / widget.seconds).clamp(0.0, 1.0);

    return Column(
      children: [
        // ── Time label ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: _barColor,
                ),
                const SizedBox(width: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: _remaining <= 5 ? 16 : 13,
                    fontWeight: FontWeight.w700,
                    color: _barColor,
                  ),
                  child: Text('${_remaining}s'),
                ),
              ],
            ),
            Text(
              _remaining > 20
                  ? 'Take your time'
                  : _remaining > 10
                  ? 'Keep going!'
                  : _remaining > 5
                  ? 'Hurry up!'
                  : 'Time running out!',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                color: _barColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Bar track ───────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.darkBorder,
              valueColor: AlwaysStoppedAnimation(_barColor),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}