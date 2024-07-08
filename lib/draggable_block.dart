import 'package:flutter/material.dart';

class DraggableBlock extends StatelessWidget {
  final Offset originalPosition;
  final Widget child;
  final Function() onDragEnd;
  const DraggableBlock({
    super.key,
    required this.originalPosition,
    required this.child,
    required this.onDragEnd,
  });

  void _onDragEnd(DraggableDetails event) {
    onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Draggable(
        feedback: child,
        onDragEnd: _onDragEnd,
        childWhenDragging: Container(),
        child: SizedBox(width: 100.0, height: 100.0, child: child),
      ),
    );
  }
}
