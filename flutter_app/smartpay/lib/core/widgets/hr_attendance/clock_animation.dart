/// Purpose: Clock animation widget that changes time every second

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ClockAnimation extends StatefulWidget {
  final Duration startDuration;
  final TextStyle textStyle;

  final String? sep;

  const ClockAnimation(
      {super.key,
      required this.startDuration,
      required this.textStyle,
      this.sep});

  @override
  State<ClockAnimation> createState() => _ClockAnimationState();
}

class _ClockAnimationState extends State<ClockAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  late Timer _timer;
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.startDuration;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = _duration + const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _getHours() {
    return _duration.inHours.toString().padLeft(2, '0');
  }

  String _getMinutes() {
    return _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  }

  String _getSeconds() {
    return _duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.rotate(
        angle: 2 * pi * _animation.value,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getHours(), style: widget.textStyle),
            Text(widget.sep ?? ':', style: widget.textStyle),
            Text(_getMinutes(), style: widget.textStyle),
            Text(widget.sep ?? ':', style: widget.textStyle),
            Text(_getSeconds(), style: widget.textStyle),
          ],
        ),
      ),
    );
  }
}
