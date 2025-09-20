import 'package:flutter/material.dart';

class AnimatedRoundButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final double diameter;
  final VoidCallback onPressed;

  const AnimatedRoundButton({
    super.key,
    required this.label,
    this.color = Colors.green,
    this.textColor = Colors.white,
    this.diameter = 72.0,
    required this.onPressed,
  });

  @override
  State<AnimatedRoundButton> createState() => AnimatedRoundButtonState();
}

class AnimatedRoundButtonState extends State<AnimatedRoundButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> playAnimation() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: SizedBox(
          width: widget.diameter,
          height: widget.diameter,
          child: Ink(
            decoration: ShapeDecoration(
              color: widget.color,
              shape: const CircleBorder(),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _onTap,
              child: Center(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


