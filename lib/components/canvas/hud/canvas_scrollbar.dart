
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/pages/editor/editor.dart';

class CanvasScrollbar extends StatefulWidget {
  const CanvasScrollbar({
    super.key,
    required this.transformationController,
    required this.pages,
    required this.containerWidth,
    required this.containerHeight,
  });

  final TransformationController transformationController;
  final List<EditorPage> pages;
  final double containerWidth;
  final double containerHeight;

  @override
  State<CanvasScrollbar> createState() => _CanvasScrollbarState();
}

class _CanvasScrollbarState extends State<CanvasScrollbar> {
  // Thumb dimensions
  static const double _thumbWidth = 6.0;
  static const double _minThumbHeight = 40.0;
  static const double _rightMargin = 4.0;
  
  // State for dragging
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    widget.transformationController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  double _calculateTotalHeight() {
    if (widget.pages.isEmpty) return widget.containerHeight;
    
    // Calculate total height similar to CanvasGestureDetector logic
    // We assume pages are laid out vertically with gaps
    
    double totalHeight = Editor.gapBetweenPages * 2; // Top gap
    
    for (final page in widget.pages) {
      final pageWidthFitted = min(page.size.width, widget.containerWidth);
      final pageHeight = pageWidthFitted / page.size.width * page.size.height;
      
      totalHeight += pageHeight;
      totalHeight += Editor.gapBetweenPages;
    }
    
    return max(totalHeight, widget.containerHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) return const SizedBox.shrink();

    final matrix = widget.transformationController.value;
    final scale = matrix.approxScale;
    final translation = matrix.getTranslation(); // x, y, z
    final scrollY = -translation.y; // Positive when scrolled down

    final contentHeight = _calculateTotalHeight() * scale;
    final viewHeight = widget.containerHeight;
    
    // If content fits in view, no scrollbar needed
    if (contentHeight <= viewHeight) return const SizedBox.shrink();

    // Calculate scroll progress (0.0 to 1.0)
    final double maxScroll = contentHeight - viewHeight;
    // ensure within bounds [0, maxScroll]
    final double clampedScroll = scrollY.clamp(0.0, maxScroll);
    
    // progress
    final double progress = clampedScroll / maxScroll;

    // Calculate thumb height
    // Proportion of view visible
    final double visibleRatio = viewHeight / contentHeight;
    final double thumbHeight = max(
      viewHeight * visibleRatio,
      _minThumbHeight,
    );
    
    // Track area height (available vertical space for thumb to move)
    final double trackHeight = viewHeight;
    final double availableMovement = trackHeight - thumbHeight;
    
    // Thumb top position
    final double thumbTop = progress * availableMovement;

    return Positioned(
      right: _rightMargin,
      top: 0,
      bottom: 0,
      width: _thumbWidth + 20, // Hit detection area larger than visual
      child: GestureDetector(
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragEnd: (_) => setState(() => _isDragging = false),
        onVerticalDragCancel: () => setState(() => _isDragging = false),
        onVerticalDragUpdate: (details) {
          if (availableMovement <= 0) return;
          
          final addedScroll = (details.delta.dy / availableMovement) * maxScroll;
          
          final currentMatrix = widget.transformationController.value;
          final currentTranslation = currentMatrix.getTranslation();
          
          // Current scrollY is -currentTranslation.y
          // We want to add 'addedScroll' to the scrollY.
          // NewScrollY = ScrollY + addedScroll
          // NewTranslationY = -(ScrollY + addedScroll) = -ScrollY - addedScroll = currentTranslation.y - addedScroll
          
          double newY = currentTranslation.y - addedScroll;
          
          // Clamp values
          // maxScroll corresponds to translation = -maxScroll
          // minScroll (0) corresponds to translation = 0
          
          // Ensure newY is between -maxScroll and 0
          if (newY > 0) newY = 0;
          if (newY < -maxScroll) newY = -maxScroll;
          
          currentMatrix.setTranslationRaw(
            currentTranslation.x,
            newY,
            currentTranslation.z
          );
          
          widget.transformationController.value = currentMatrix;
        },
        child: Container(
          color: Colors.transparent, // Hit test invisible
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: thumbTop,
                height: thumbHeight,
                width: _thumbWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDragging 
                        ? Colors.grey.withValues(alpha: 0.8) 
                        : Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(_thumbWidth / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
