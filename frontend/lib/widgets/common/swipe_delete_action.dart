import 'package:flutter/material.dart';

import 'responsive.dart';

/// Reveals a delete action without dismissing the item on a full swipe.
class SwipeDeleteAction extends StatefulWidget {
  const SwipeDeleteAction({
    super.key,
    required this.child,
    required this.onDelete,
    this.isDeleting = false,
  });

  final Widget child;
  final VoidCallback? onDelete;
  final bool isDeleting;

  @override
  State<SwipeDeleteAction> createState() => _SwipeDeleteActionState();
}

class _SwipeDeleteActionState extends State<SwipeDeleteAction>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  bool _actionPending = false;

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (widget.isDeleting || _actionPending || widget.onDelete == null) return;
    _actionPending = true;
    try {
      await _animation.reverse().orCancel;
      if (mounted && !widget.isDeleting) widget.onDelete?.call();
    } on TickerCanceled {
      // The row can disappear while the action is closing.
    } finally {
      _actionPending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onDelete == null) return widget.child;
    final actionWidth = context.rs(76).clamp(56.0, 96.0);
    final enabled = !widget.isDeleting && !_actionPending;
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.rs(12)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: enabled ? (_) => _animation.stop() : null,
        onHorizontalDragUpdate: enabled
            ? (details) {
                _animation.value =
                    (_animation.value - details.delta.dx / actionWidth).clamp(
                      0.0,
                      1.0,
                    );
              }
            : null,
        onHorizontalDragEnd: enabled
            ? (details) {
                final velocity = details.primaryVelocity ?? 0;
                final open =
                    velocity < -300 ||
                    (velocity <= 300 && _animation.value >= 0.5);
                if (open) {
                  _animation.forward();
                } else {
                  _animation.reverse();
                }
              }
            : null,
        onHorizontalDragCancel: () => _animation.reverse(),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Stack(
            children: [
              if (_animation.value > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: actionWidth,
                  child: Material(
                    color: const Color(0xFFE65C58),
                    child: Tooltip(
                      message: '일정 삭제',
                      child: InkWell(
                        onTap: enabled ? _delete : null,
                        child: const Center(
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(-actionWidth * _animation.value, 0),
                child: GestureDetector(
                  onTap: _animation.value > 0
                      ? () => _animation.reverse()
                      : null,
                  child: AbsorbPointer(
                    absorbing: _animation.value > 0 || widget.isDeleting,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
