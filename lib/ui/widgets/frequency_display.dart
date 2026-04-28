import 'package:flutter/material.dart';
import '../../core/constants/frequencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/radio_theme.dart';
import '../../core/utils/formatters.dart';

class FrequencyDisplay extends StatelessWidget {
  final double dialPosition;
  final Band band;
  final String? stationName;
  final bool hasError;

  const FrequencyDisplay({
    super.key,
    required this.dialPosition,
    required this.band,
    this.stationName,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    final freqStr = Formatters.frequencyFromPosition(dialPosition, band);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            freqStr,
            style: AppTypography.frequencyLarge.copyWith(
              color: theme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: stationName != null
                ? _MarqueeText(
                    key: ValueKey(stationName),
                    text: stationName!.toUpperCase(),
                    style: AppTypography.stationName.copyWith(
                      color: theme.textSecondary,
                    ),
                  )
                : Text(
                    '– – –',
                    key: const ValueKey('no_station'),
                    style: AppTypography.stationName.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
          ),
          if (hasError)
            Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 10,
                  color: AppColors.dialNeedle,
                ),
                Text(
                  'Stasiun tidak tersedia'.toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.dialNeedle,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({super.key, required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _textWidth = 0;
  double _textHeight = 0;

  static const _gap = 24.0;
  static const _speed = 40.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  @override
  void didUpdateWidget(_MarqueeText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      _controller.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
    }
  }

  void _setup() {
    if (!mounted) return;
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = tp.width;
    _textHeight = tp.height;
    setState(() {});

    final loopWidth = _textWidth + _gap;
    _controller.duration = Duration(
      milliseconds: (loopWidth / _speed * 1000).toInt(),
    );
    if (mounted) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_textWidth == 0) {
      return Text(widget.text, style: widget.style, maxLines: 1);
    }
    final loopWidth = _textWidth + _gap;
    // 48 = 24px padding on each side applied in FrequencyDisplay
    final containerWidth = MediaQuery.of(context).size.width - 48;
    final copies = (containerWidth / loopWidth).ceil() + 2;

    return SizedBox(
      width: containerWidth,
      height: _textHeight,
      child: ShaderMask(
        shaderCallback: (bounds) {
          if (bounds.isEmpty) {
            return const LinearGradient(
              colors: [Colors.white, Colors.white],
            ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
          }
          return const LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.1, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.translate(
              offset: Offset(-(_controller.value * loopWidth), 0),
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: _textHeight,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < copies; i++) ...[
                      Text(widget.text, style: widget.style),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _gap / 2,
                        ),
                        child: Text('•', style: widget.style),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
