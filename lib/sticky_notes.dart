library sticky_notes;

import 'package:flutter/material.dart';

/// A draggable, interactive sticky note widget.
///
/// Features:
/// - Drag & drop within a bounded board area
/// - Animated preview with InteractiveViewer
/// - Context menu (edit, color, delete)
/// - Flexible content (`child`) for any widget type
/// - Callbacks for edit, color change, delete, and position change
class StickyNote extends StatefulWidget {
  /// Creates a new sticky note.
  const StickyNote({
    super.key,
    required this.id,
    required this.size,
    required this.initialPosition,
    required this.child,
    required this.boardSize,
    this.previewChild,
    this.initialColor = Colors.yellow,
    this.availableColors = const [],
    this.onEdit,
    this.onDelete,
    this.onPositionChanged,
    this.onColorChanged,
    this.minVisibleArea = 32,
    this.onPanStart,
    this.onTap,
    this.colorLabel = 'Color',
    this.editLabel = 'Edit',
    this.deleteLabel = 'Delete',
    this.pickColorTitle = 'Pick color',
    this.syncWithInitialPosition = false,
  });

  /// Unique identifier of the sticky note.
  final String id;

  /// Size of the sticky note.
  final Size size;

  /// Initial position on the board.
  final Offset initialPosition;

  /// The color of the sticky note.
  final Color initialColor;

  /// The widget displayed inside the note.
  final Widget child;

  /// Optional widget used in the expanded preview.
  final Widget? previewChild;

  /// List of colors available for selection.
  final List<Color> availableColors;

  /// Minimum visible area when dragged to board edges.
  final double minVisibleArea;

  /// Size of the board (used to constrain dragging).
  final Size boardSize;

  /// Callback when the note is edited.
  final VoidCallback? onEdit;

  /// Callback when the note is deleted.
  final VoidCallback? onDelete;

  /// Callback when the note's position changes.
  final ValueChanged<Offset>? onPositionChanged;

  /// Callback when the note's color changes.
  final ValueChanged<Color>? onColorChanged;

  /// Text for the "change color" menu item.
  final String colorLabel;

  /// Text for the "edit" menu item.
  final String editLabel;

  /// Text for the "delete" menu item.
  final String deleteLabel;

  /// Title for the color picker dialog.
  final String pickColorTitle;

  /// Callback when the user starts dragging the note.
  final VoidCallback? onPanStart;

  /// Callback when the note is tapped.
  final VoidCallback? onTap;

  /// If true, the note will update its position to match `initialPosition` whenever it changes.
  /// This allows external control of the note's position.
  final bool syncWithInitialPosition;

  @override
  State<StickyNote> createState() => _StickyNoteState();
}

class _StickyNoteState extends State<StickyNote> {
  late Offset _position;
  late Color _color;
  final MenuController _menuController = MenuController();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _color = widget.initialColor;
  }

  @override
  void didUpdateWidget(covariant StickyNote oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.syncWithInitialPosition) {
      _position = widget.initialPosition;
    }

    if (widget.initialColor != oldWidget.initialColor) {
      _color = widget.initialColor;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.onPanStart != null) widget.onPanStart!();
  }

  void _onTap() {
    if (widget.onTap != null) widget.onTap!();
  }

  /// Shows an animated, zoomable preview of the note.
  void _showPreview() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(parent: animation, curve: Curves.easeOutBack).value;
        final opacity = animation.value;
        final screenSize = MediaQuery.of(context).size;
        final noteRatio = widget.size.width / widget.size.height;
        double maxWidth = screenSize.width * 0.9;
        double maxHeight = screenSize.height * 0.9;
        double width = maxWidth;
        double height = width / noteRatio;
        if (height > maxHeight) {
          height = maxHeight;
          width = height * noteRatio;
        }
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    color: _color,
                    elevation: 8,
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: InteractiveViewer(
                        clipBehavior: Clip.hardEdge,
                        panEnabled: true,
                        boundaryMargin: EdgeInsets.zero,
                        minScale: 1.0,
                        maxScale: 3.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: widget.size.width,
                            height: widget.size.height,
                            child: widget.previewChild ?? widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Opens a color picker dialog and updates the note color.
  Future<void> _pickColor() async {
    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(widget.pickColorTitle),
        children: widget.availableColors
            .map(
              (color) => GestureDetector(
                onTap: () => Navigator.pop(context, color),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selectedColor != null) {
      setState(() => _color = selectedColor);
      widget.onColorChanged?.call(selectedColor);
    }
  }

  /// Handles dragging and constrains the note within the board.
  void _onPanUpdate(DragUpdateDetails details) {
    final minX = -widget.size.width + widget.minVisibleArea;
    final minY = -widget.size.height + widget.minVisibleArea;
    final maxX = widget.boardSize.width - widget.minVisibleArea;
    final maxY = widget.boardSize.height - widget.minVisibleArea;

    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(minX, maxX),
        (_position.dy + details.delta.dy).clamp(minY, maxY),
      );
    });
  }

  /// Callback when dragging ends.
  void _onPanEnd(DragEndDetails details) {
    widget.onPositionChanged?.call(_position);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: MenuAnchor(
        alignmentOffset: Offset(widget.size.width, -widget.size.height),
        controller: _menuController,
        menuChildren: [
          if (widget.availableColors.isNotEmpty)
            MenuItemButton(
              onPressed: () {
                _menuController.close();
                _pickColor();
              },
              child: Text(widget.colorLabel),
            ),
          MenuItemButton(
            onPressed: () {
              _menuController.close();
              widget.onEdit?.call();
            },
            child: Text(widget.editLabel),
          ),
          MenuItemButton(
            onPressed: () {
              _menuController.close();
              widget.onDelete?.call();
            },
            child: Text(widget.deleteLabel),
          ),
        ],
        builder: (context, controller, child) {
          return GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onLongPress: () => controller.open(),
            onTap: () {
              _onTap();
              _showPreview();
            },
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: _color,
              child: SizedBox(
                width: widget.size.width,
                height: widget.size.height,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
