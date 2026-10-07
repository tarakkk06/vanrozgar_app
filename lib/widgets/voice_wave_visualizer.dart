import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VoiceWaveVisualizer extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;

  const VoiceWaveVisualizer({
    Key? key,
    this.isRecording = false,
    this.isPlaying = false,
  }) : super(key: key);

  @override
  State<VoiceWaveVisualizer> createState() => _VoiceWaveVisualizerState();
}

class _VoiceWaveVisualizerState extends State<VoiceWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool active = widget.isRecording || widget.isPlaying;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            double height = active
                ? 8.0 + (index % 3 == 0 ? _controller.value * 22 : (1.0 - _controller.value) * 18)
                : 6.0;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: height,
              decoration: BoxDecoration(
                color: widget.isRecording
                    ? AppColors.secondaryOrange
                    : (widget.isPlaying ? AppColors.usefulGreen : AppColors.textLight),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }
}
