library sticky_notes;

import 'package:flutter/material.dart';

class StickyNote extends StatefulWidget {
  const StickyNote({
    super.key,
    this.id = -1,
    this.color = Colors.yellow,
    this.onDelete,
    this.onEdit,
    this.colorsEdit = const [],
    this.removeOptionName = 'Delete',
    this.colorOptionName = 'Color',
    this.editOptionName = 'Edit',
    required this.width,
    required this.height,
    required this.child,
  });
  final int id;
  final Color color;
  final double width;
  final double height;
  final Widget child;

  final String colorOptionName;
  final List<Color> colorsEdit;

  final String removeOptionName;
  final Function()? onDelete;
  final String editOptionName;
  final Function()? onEdit;

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  Offset _position = const Offset(0, 0);
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

                setState(() {
                  _position = Offset(newPosX, newPosY);
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
