import 'package:flutter/material.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:foodie/widgets/map/preference_overlay.dart';

class PreferenceButton extends StatefulWidget {
  final FilterOptions options;
  final Function(FilterOptions) onUpdate;

  const PreferenceButton({Key? key, required this.options, required this.onUpdate})
    : super(key: key);

  @override
  State<PreferenceButton> createState() => _PreferenceButtonState();
}

class _PreferenceButtonState extends State<PreferenceButton> with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _toggleOverlay() async {
    FocusScope.of(context).unfocus();

    if (!_isOverlayVisible) {
      setState(() {
        _isOverlayVisible = true;
      });

      final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
      _overlayEntry = OverlayEntry(
        builder:
            (context) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              )),
              child: PreferenceOverlay(
                buttonRenderBox: renderBox,
                onClose: _toggleOverlay,
                initialOptions: widget.options,
                onUpdate: widget.onUpdate,
              ),
            ),
      );
      Overlay.of(context).insert(_overlayEntry!);
      _animationController.forward();
    } else {
      await _animationController.reverse();

      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        _isOverlayVisible
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final double borderWidth = _isOverlayVisible ? 2.0 : 1.0;
    final Color iconColor =
        _isOverlayVisible
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      key: _buttonKey,
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _toggleOverlay,
        child: Icon(Icons.tune, color: iconColor),
      ),
    );
  }
}
