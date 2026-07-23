import 'package:flutter/material.dart';

class SlideToConfirm extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onConfirmed;
  final Color background;
  final Color foreground;

  final bool enabled;

  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    required this.background,
    required this.foreground,
    this.enabled = true,
    this.icon = Icons.keyboard_double_arrow_right_rounded,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _dragX = 0;
  bool _dragging = false;
  bool _done = false;

  double? _grabOffset;

  static const double _h = 58;
  static const double _thumb = 50;
  static const double _pad = 4;

  void _confirm(double maxX) {
    if (_done) return;
    setState(() {
      _dragging = false;
      _done = true;
      _dragX = maxX;
    });
    widget.onConfirmed();
  }

  void _reset() {
    _grabOffset = null;
    setState(() {
      _dragging = false;
      _dragX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    final bg = active ? widget.background : Theme.of(context).disabledColor;

    return LayoutBuilder(
      builder: (context, c) {
        final maxX =
            (c.maxWidth - _thumb - _pad * 2).clamp(0.0, double.infinity);
        final progress = maxX <= 0 ? 0.0 : (_dragX / maxX).clamp(0.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (!active || _done)
              ? null
              : (d) {
                  final thumbLeft = _pad + _dragX;
                  final x = d.localPosition.dx;
                  if (x >= thumbLeft - 16 && x <= thumbLeft + _thumb + 16) {
                    _grabOffset = (x - thumbLeft).clamp(0.0, _thumb);
                    setState(() => _dragging = true);
                  } else {
                    _grabOffset = null;
                  }
                },
          onHorizontalDragUpdate: (!active || _done)
              ? null
              : (d) {
                  if (_grabOffset == null) return;
                  setState(() {
                    _dragX = (d.localPosition.dx - _grabOffset! - _pad)
                        .clamp(0.0, maxX);
                  });
                  if (_dragX >= maxX - 1) _confirm(maxX);
                },
          onHorizontalDragEnd: (!active || _done)
              ? null
              : (_) {
                  if (_grabOffset == null) return;
                  _grabOffset = null;
                  if (_dragX >= maxX * 0.85) {
                    _confirm(maxX);
                  } else {
                    _reset();
                  }
                },
          onHorizontalDragCancel: () {
            if (_done || _grabOffset == null) return;
            _reset();
          },
          child: Container(
            height: _h,
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(_h / 2),
              border: Border.all(color: bg.withValues(alpha: 0.35), width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: (1 - progress).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: _thumb),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: bg,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: _dragging ? 0 : 220),
                  curve: Curves.easeOut,
                  left: _pad + _dragX,
                  top: _pad,
                  bottom: _pad,
                  child: Container(
                    width: _thumb,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(_h / 2),
                    ),
                    child:
                        Icon(widget.icon, color: widget.foreground, size: 26),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
