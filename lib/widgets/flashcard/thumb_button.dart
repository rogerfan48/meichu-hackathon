import 'package:flutter/material.dart';

class AnimatedThumbButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const AnimatedThumbButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<AnimatedThumbButton> createState() => _AnimatedThumbButtonState();
}

class _AnimatedThumbButtonState extends State<AnimatedThumbButton>
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 32,
        ),
      ),
    );
  }
}
