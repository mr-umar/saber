import 'package:flutter/material.dart';

class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    super.key,
    this.tooltip,
    this.selected = false,
    this.enabled = true,
    required this.onPressed,
    required this.padding,
    this.iconSize = 20,
    this.innerPadding = const EdgeInsets.all(8),
    required this.child,
  });

  final String? tooltip;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  final EdgeInsets padding;
  final double iconSize;
  final EdgeInsets innerPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled) ||
          !states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return colorScheme.primary;
    });
    final foregroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.onSurface.withValues(alpha: 0.4);
      }
      if (states.contains(WidgetState.selected)) {
        return colorScheme.onPrimary;
      }
      return colorScheme.primary;
    });
    final buttonStyle = ButtonStyle(
      backgroundColor: backgroundColor,
      iconColor: foregroundColor,
      foregroundColor: foregroundColor,
      iconSize: WidgetStatePropertyAll(iconSize),
      padding: WidgetStatePropertyAll(innerPadding),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const WidgetStatePropertyAll(Size.zero),
    );

    return Padding(
      padding: padding,
      child: SizedBox(
        width: iconSize + innerPadding.horizontal,
        height: iconSize + innerPadding.vertical,
        child: IconButton.filled(
          style: buttonStyle,
          onPressed: (enabled) ? onPressed : null,
          tooltip: tooltip,
          isSelected: selected,
          icon: child,
        ),
      ),
    );
  }
}
