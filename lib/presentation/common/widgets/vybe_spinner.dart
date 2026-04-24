import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vybe/design_system/colors.dart';

class VybeSpinner extends StatefulWidget {
  final double size;

  const VybeSpinner({super.key, this.size = 50.0});

  @override
  State<VybeSpinner> createState() => _VybeSpinnerState();
}

class _VybeSpinnerState extends State<VybeSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final List<Color> _colors = [
    VybeColors.mainPurple500,
    VybeColors.mainLime500,
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation =
        ColorTween(begin: _colors[0], end: _colors[1]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.status == AnimationStatus.completed) {
          _colors.add(_colors.removeAt(0));
        }

        return SpinKitWave(
          color: _colorAnimation.value,
          size: widget.size,
          duration: const Duration(milliseconds: 1400),
        );
      },
    );
  }
}
