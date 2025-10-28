import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A modern, animated custom checkbox widget with professional styling.
///
/// Features:
/// - Smooth animations and transitions
/// - Customizable colors and sizing
/// - Professional shadow effects
/// - Responsive design with ScreenUtil
/// - Accessibility support
///
/// Usage:
/// ```dart
/// CustomCheckboxWidget(
///   value: isChecked,
///   onChanged: (value) => setState(() => isChecked = value),
///   activeColor: Colors.blue,
///   size: 24,
/// )
/// ```
class CustomCheckboxWidget extends StatefulWidget {
  /// Whether the checkbox is checked
  final bool value;

  /// Size of the checkbox (defaults to 20.w)
  final double? size;

  /// Right padding (currently unused, kept for compatibility)
  final double rightPadding;

  /// Width of the border
  final double borderWidth;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Color when checkbox is checked
  final Color? activeColor;

  /// Color of the checkmark icon
  final Color? checkColor;

  /// Color of the border when unchecked
  final Color? borderColor;

  /// Callback when checkbox state changes
  final Function(bool?) onChanged;

  /// Whether the checkbox is enabled for interaction
  final bool enabled;

  const CustomCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
    this.rightPadding = 10,
    this.borderWidth = 2,
    this.borderRadius = 4,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.enabled = true,
  });

  @override
  State<CustomCheckboxWidget> createState() => _CustomCheckboxWidgetState();
}

class _CustomCheckboxWidgetState extends State<CustomCheckboxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomCheckboxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 20.w;
    final activeColor = widget.activeColor ?? const Color(0xFF667eea);
    final checkColor = widget.checkColor ?? Colors.white;
    final borderColor = widget.borderColor ?? Colors.grey.withOpacity(0.5);

    return GestureDetector(
      onTap: widget.enabled ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: widget.value ? activeColor : Colors.transparent,
                border: Border.all(
                  color: widget.value ? activeColor : borderColor,
                  width: widget.borderWidth,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.value
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: widget.value
                  ? Icon(
                      Icons.check,
                      size: size * 0.6,
                      color: checkColor,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _handleTap() {
    if (widget.enabled) {
      // Add subtle animation feedback
      _animationController.forward().then((_) {
        if (mounted) {
          widget.onChanged(!widget.value);
        }
      });
    }
  }
}
