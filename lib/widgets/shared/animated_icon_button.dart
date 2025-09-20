import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  // ** 關鍵修正 1：允許 onPressed 為 null **
  final VoidCallback? onPressed;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  State<AnimatedIconButton> createState() => AnimatedIconButtonState();
}

class AnimatedIconButtonState extends State<AnimatedIconButton>
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
    if (!mounted) return;
    await _controller.forward();
    if (!mounted) return;
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    // ** 關鍵修正 2：在呼叫前檢查是否為 null **
    // ?. 語法糖會在 onPressed 不為 null 時才呼叫 call()
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    // ** 關鍵修正 3：當 onPressed 為 null 時，停用 GestureDetector 的 onTap 事件 **
    return GestureDetector(
      onTap: widget.onPressed != null ? _onTap : null,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.icon,
          color: widget.onPressed != null ? widget.color : Colors.grey.shade400, // 停用時顯示灰色
          size: 32,
        ),
      ),
    );
  }
}