library sticky_notes;

import 'package:flutter/material.dart';

/// Draggable StickyNote with child Widget, 3 options menu upon [onLongPress] and zoom with [InteractiveViewer] [onTap].
// ignore: must_be_immutable
class StickyNote extends StatefulWidget {
  ///
  /// Creates StickyNote which must be child to [Stack].
  StickyNote({
    super.key,
    this.id = -1,
    this.color = Colors.yellow,
    this.onDelete,
    this.onEdit,
    this.onDragEnd,
    this.colorsEdit = const [],
    this.removeOptionName = 'Delete',
    this.colorOptionName = 'Color',
    this.editOptionName = 'Edit',
    this.startingPosition = const Offset(0, 0),
    required this.width,
    required this.height,
    required this.child,
  });

  /// Note id.
  final int id;

  /// Note color.
  Color color;

  /// Note width.
  final double width;

  /// Note height.
  final double height;

  /// Starting position of note's top left corner related to parent.
  final Offset startingPosition;

  /// Child [Widget] that is displayed inside note.
  final Widget child;

  /// Name of first option in menu after [onLongPress] on note.
  final String editOptionName;

  /// Function running after first option in menu is pressed.
  final Function()? onEdit;

  /// Name of color change option (second) in menu after [onLongPress] on note.
  final String colorOptionName;

  /// List of available colors in changing color menu.
  final List<Color> colorsEdit;

  /// Name of third option in menu after [onLongPress] on note.
  final String removeOptionName;

  /// Function running after third option in menu is pressed.
  final Function()? onDelete;

  /// Function running after user ends dragging note. It's argument is position of note related to parent.
  final Function(Offset)? onDragEnd;

  /// Current note position property. Returns [Offset] value, top left corner of parent widget is (0,0).
  late Offset position = startingPosition;

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  late Offset _position;
  Offset _containerPosition = const Offset(0, 0);

  late final double _maxPositionY;
  late final double _minPositionY;
  late final double _maxPositionX;
  late final double _minPositionX;

  late Color _noteColor;

  @override
  void initState() {
    super.initState();
    _noteColor = widget.color;
    _position = widget.startingPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // get position of parent widget so position can be calculated inlcuding this
      final renderBox = context.findRenderObject() as RenderBox;
      _containerPosition = renderBox.localToGlobal(Offset.zero);

      _position = _containerPosition;

      // coordinates beyond which user can't drag note
      _maxPositionX =
          renderBox.size.width + _containerPosition.dx - widget.width;
      _minPositionX = _containerPosition.dx;
      _maxPositionY =
          renderBox.size.height + _containerPosition.dy - widget.height;
      _minPositionY = _containerPosition.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            left: _position.dx - _containerPosition.dx,
            top: _position.dy - _containerPosition.dy,
            child: Draggable(
              onDraggableCanceled: (velocity, offset) {
                double newPosX, newPosY;

                if (offset.dx > _maxPositionX) {
                  newPosX = _maxPositionX;
                } else if (offset.dx < _minPositionX) {
                  newPosX = _minPositionX;
                } else {
                  newPosX = offset.dx;
                }

                if (offset.dy > _maxPositionY) {
                  newPosY = _maxPositionY;
                } else if (offset.dy < _minPositionY) {
                  newPosY = _minPositionY;
                } else {
                  newPosY = offset.dy;
                }
                if (widget.onDragEnd != null) {
                  // function with argument of current position (inside parent) of note's top left vertex
                  widget.onDragEnd!(Offset(newPosX - _containerPosition.dx,
                      newPosY - _containerPosition.dy));
                }
                setState(() {
                  _position = Offset(newPosX, newPosY);
                  widget.position = _position;
                });
              },
              feedback: GestureDetector(
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  color: _noteColor,
                  child: widget.child,
                ),
              ),
              child: GestureDetector(
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  color: _noteColor,
                  child: widget.child,
                ),
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: ((context) {
                        return AlertDialog(
                          backgroundColor: _noteColor,
                          content: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: 0,
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 2),
                              child: InteractiveViewer(
                                  child: Center(child: widget.child))),
                        );
                      }));
                },
                onLongPress: () async {
                  await showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        _position.dx + widget.width,
                        _position.dy,
                        _position.dx + widget.width,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          child: Text(widget.colorOptionName),
                          onTap: () async {
                            List<PopupMenuItem> colorOptions = [];
                            for (var color in widget.colorsEdit) {
                              colorOptions.add(PopupMenuItem(
                                child: Container(
                                  height: kMinInteractiveDimension,
                                  color: color,
                                ),
                                onTap: () {
                                  setState(() {
                                    _noteColor = color;
                                    widget.color = _noteColor;
                                  });
                                },
                              ));
                            }
                            if (colorOptions.isNotEmpty) {
                              await showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    _position.dx + widget.width,
                                    _position.dy,
                                    _position.dx + widget.width,
                                    0,
                                  ),
                                  items: colorOptions);
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: Text(widget.editOptionName),
                          onTap: () {
                            if (widget.onEdit != null) widget.onEdit!();
                          },
                        ),
                        PopupMenuItem(
                          child: Text(widget.removeOptionName),
                          onTap: () {
                            if (widget.onDelete != null) widget.onDelete!();
                          },
                        )
                      ]);
                },
              ),
            ))
      ],
    );
  }
}
