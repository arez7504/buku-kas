import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

// Komponen penampil nominal dan chip tanggal sesuai design/catat.html
class CatatAmountDisplay extends StatefulWidget {
  final TransactionType type;
  final String formattedAmount;
  final String dateText;
  final VoidCallback onDateTap;
  final bool? enableBlink;
  final int? keypadTapEpoch;

  /// Override untuk testing kedip kursor di widget test.
  static bool? debugBlinkOverride;

  const CatatAmountDisplay({
    super.key,
    required this.type,
    required this.formattedAmount,
    required this.dateText,
    required this.onDateTap,
    this.enableBlink,
    this.keypadTapEpoch,
  });

  @override
  State<CatatAmountDisplay> createState() => _CatatAmountDisplayState();
}

class _CatatAmountDisplayState extends State<CatatAmountDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  static bool get _isInTest =>
      const bool.fromEnvironment('FLUTTER_TEST') ||
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  bool _shouldBlink(BuildContext context) {
    if (widget.enableBlink != null) {
      return widget.enableBlink!;
    }
    if (CatatAmountDisplay.debugBlinkOverride != null) {
      return CatatAmountDisplay.debugBlinkOverride!;
    }
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      return false;
    }
    if (_isInTest) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(CatatAmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formattedAmount != oldWidget.formattedAmount ||
        widget.keypadTapEpoch != oldWidget.keypadTapEpoch ||
        widget.type != oldWidget.type ||
        widget.enableBlink != oldWidget.enableBlink) {
      _resetBlink();
    }
  }

  void _updateAnimationState() {
    final shouldBlink = _shouldBlink(context);
    if (shouldBlink) {
      if (!_controller.isAnimating) {
        _controller.value = 0.0;
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  void _resetBlink() {
    final shouldBlink = _shouldBlink(context);
    if (!shouldBlink) {
      _controller.stop();
      _controller.value = 0.0;
      return;
    }
    _controller.stop();
    _controller.value = 0.0;
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLabelText() {
    switch (widget.type) {
      case TransactionType.expense:
        return 'NOMINAL PENGELUARAN';
      case TransactionType.income:
        return 'NOMINAL PEMASUKAN';
      case TransactionType.transfer:
        return 'NOMINAL TRANSFER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldBlink = _shouldBlink(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spaceMd,
        vertical: AppDimens.spaceMd,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.catatAmountCard,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: AppColors.catatCardBorder,
          width: AppDimens.borderWidthThin,
        ),
        boxShadow: AppShadows.catatAmountCard,
      ),
      child: Column(
        children: [
          Text(_getLabelText(), style: AppTypography.catatNominalLabel),
          const SizedBox(height: AppDimens.spaceXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Rp', style: AppTypography.catatAmountPrefix),
              const SizedBox(width: AppDimens.spaceXs + 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.formattedAmount, style: AppTypography.catatAmount),
                  FadeTransition(
                    key: const Key('catat_cursor_fade'),
                    opacity: shouldBlink
                        ? _opacityAnimation
                        : const AlwaysStoppedAnimation<double>(1.0),
                    child: Container(
                      width: 3.0,
                      height: 28.0,
                      margin: const EdgeInsets.only(left: 4.0),
                      decoration: BoxDecoration(
                        gradient: AppGradients.catatCursor,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceSm + 2),
          InkWell(
            onTap: widget.onDateTap,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spaceMd - AppDimens.spaceXs,
                vertical: AppDimens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.catatDateChipBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                border: Border.all(
                  color: AppColors.catatDateChipBorder,
                  width: AppDimens.borderWidthThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppDimens.spaceXs + 2),
                  Text(widget.dateText, style: AppTypography.catatDateChip),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
