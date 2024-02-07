import 'package:at_enrollment_app/utils/colors.dart';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final Function()? onDone;

  const CountdownTimerWidget({
    super.key,
    this.onDone,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.dispose();
        widget.onDone?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int countDown = (15 * (1 - _controller.value)).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$countDown',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorConstant.orange,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 24,
          width: 24,
          child: Transform.flip(
            flipX: true,
            child: RotatedBox(
              quarterTurns: -2,
              child: CircularProgressIndicator(
                value: _controller.value,
                backgroundColor: ColorConstant.orange,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    ColorConstant.timerColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
