import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sleep_timer/sleep_timer_bloc.dart';
import '../../bloc/sleep_timer/sleep_timer_event.dart';
import '../../bloc/sleep_timer/sleep_timer_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SleepTimerOverlay extends StatelessWidget {
  const SleepTimerOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SleepTimerBloc>(),
        child: const SleepTimerOverlay(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SleepTimerBloc, SleepTimerState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24, 12, 24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.buttonSecondaryBg,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Sleep Timer', style: AppTypography.appTitle),
                  if (state.isActive) ...[
                    const Spacer(),
                    Text(
                      state.formattedRemaining,
                      style: AppTypography.frequencyLarge.copyWith(
                        fontSize: 22,
                        color: AppColors.dialNeedle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                state.isActive
                    ? 'Select a new duration to change the timer.'
                    : 'Audio will fade out when the timer ends.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),

              // Duration grid — 2 columns
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.2,
                children: [
                  for (final min in const [15, 30, 45, 60, 90])
                    _FlatChip(
                      label: '$min min',
                      onTap: () {
                        context.read<SleepTimerBloc>().add(SleepTimerStarted(min));
                        Navigator.pop(context);
                      },
                    ),
                  _FlatChip(
                    label: 'Custom',
                    onTap: () => _showCustomInput(context),
                  ),
                ],
              ),

              // Cancel — only when active
              if (state.isActive) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    context.read<SleepTimerBloc>().add(const SleepTimerCancelled());
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Center(
                      child: Text(
                        'CANCEL TIMER',
                        style: AppTypography.buttonLabel.copyWith(
                          color: AppColors.dialNeedle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showCustomInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom duration', style: AppTypography.appTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 – 360',
            hintStyle: AppTypography.bodySmall,
            suffixText: 'min',
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.buttonSecondaryBg),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5),
            ),
          ),
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: AppTypography.body),
          ),
          TextButton(
            onPressed: () {
              final min = int.tryParse(controller.text);
              if (min != null && min >= 1 && min <= 360) {
                context.read<SleepTimerBloc>().add(SleepTimerStarted(min));
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Set',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FlatChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.buttonSecondaryBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(label, style: AppTypography.bandLabel),
        ),
      ),
    );
  }
}
