import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/canvas/hud/canvas_gesture_lock_btn.dart';
import 'package:saber/components/canvas/hud/canvas_zoom_indicator.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class CanvasHud extends StatefulWidget {
  const CanvasHud({
    super.key,
    required this.transformationController,
    required this.zoomLock,
    required this.setZoomLock,
    required this.resetZoom,
    required this.singleFingerPanLock,
    required this.setSingleFingerPanLock,
    required this.axisAlignedPanLock,
    required this.setAxisAlignedPanLock,
    required this.horizontalScrollLock,
    required this.setHorizontalScrollLock,
    required this.toolbarSize,
  });
  
  final TransformationController transformationController;
  final bool zoomLock;
  final ValueChanged<bool> setZoomLock;
  final VoidCallback? resetZoom;
  final bool singleFingerPanLock;
  final ValueChanged<bool> setSingleFingerPanLock;
  final bool axisAlignedPanLock;
  final ValueChanged<bool> setAxisAlignedPanLock;
  final bool horizontalScrollLock;
  final ValueChanged<bool> setHorizontalScrollLock;
  final ToolbarSize toolbarSize;

  @override
  State<CanvasHud> createState() => _CanvasHudState();
}

class _CanvasHudState extends State<CanvasHud> {
  Timer? _hideTimer;
  double opacity = 0;

  @override
  void initState() {
    widget.transformationController.addListener(_onTransformationChanged);
    super.initState();
  }

  void _onTransformationChanged() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() => opacity = 0);
    });

    if (opacity != 1) {
      setState(() => opacity = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (iconSize, padding, spacing) = switch (widget.toolbarSize) {
      ToolbarSize.small => (18.0, const EdgeInsets.all(4.0), 36.0),
      ToolbarSize.medium => (24.0, const EdgeInsets.all(5.0), 40.0),
      ToolbarSize.large => (30.0, const EdgeInsets.all(6.0), 48.0),
    };

    return IgnorePointer(
      ignoring: opacity < 0.5,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 200),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: widget.zoomLock,
                setLock: widget.setZoomLock,
                icon: widget.zoomLock ? Icons.lock : Icons.lock_open,
                tooltip: widget.zoomLock
                    ? t.editor.hud.unlockZoom
                    : t.editor.hud.lockZoom,
                iconSize: iconSize,
                padding: padding,
              ),
            ),
            Positioned(
              top: 5 + spacing,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: widget.singleFingerPanLock,
                setLock: widget.setSingleFingerPanLock,
                icon: widget.singleFingerPanLock ? Icons.pinch : Icons.swipe_up,
                tooltip: widget.singleFingerPanLock
                    ? t.editor.hud.unlockSingleFingerPan
                    : t.editor.hud.lockSingleFingerPan,
                iconSize: iconSize,
                padding: padding,
              ),
            ),
            Positioned(
              top: 5 + spacing * 2,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: widget.axisAlignedPanLock,
                setLock: widget.setAxisAlignedPanLock,
                tooltip: widget.axisAlignedPanLock
                    ? t.editor.hud.unlockAxisAlignedPan
                    : t.editor.hud.lockAxisAlignedPan,
                iconSize: iconSize,
                padding: padding,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: widget.axisAlignedPanLock ? 0 : 1 / 8,
                  child: Icon(Symbols.drag_pan, size: iconSize),
                ),
              ),
            ),
            Positioned(
              top: 5 + spacing * 3,
              left: 5,
              child: CanvasGestureLockBtn(
                lock: widget.horizontalScrollLock,
                setLock: widget.setHorizontalScrollLock,
                tooltip: widget.horizontalScrollLock
                    ? "Unlock Horizontal Scroll"
                    : "Lock Horizontal Scroll",
                icon: widget.horizontalScrollLock
                    ? Icons.swap_vert
                    : Icons.swap_horiz,
                iconSize: iconSize,
                padding: padding,
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: AnimatedBuilder(
                animation: widget.transformationController,
                builder: (context, _) => CanvasZoomIndicator(
                  scale: widget.transformationController.value.approxScale,
                  resetZoom: widget.resetZoom,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_onTransformationChanged);
    _hideTimer?.cancel();
    super.dispose();
  }
}
