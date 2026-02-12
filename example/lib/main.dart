import 'package:flutter/material.dart';
import 'package:sticky_notes/sticky_notes.dart';

void main() {
  runApp(const StickyNotesExampleApp());
}

class StickyNotesExampleApp extends StatelessWidget {
  const StickyNotesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StickyNotesDemo(),
    );
  }
}

/// Simple note model used only in the example.
class NoteModel {
  final String id;
  Offset position;
  Color color;
  String text;

  NoteModel({
    required this.id,
    required this.position,
    required this.color,
    required this.text,
  });
}

class StickyNotesDemo extends StatefulWidget {
  const StickyNotesDemo({super.key});

  @override
  State<StickyNotesDemo> createState() => _StickyNotesDemoState();
}

class _StickyNotesDemoState extends State<StickyNotesDemo> {
  final Size boardSize = const Size(350, 550);

  final List<NoteModel> _notes = [
    NoteModel(
      id: '1',
      position: const Offset(20, 20),
      color: Colors.yellow,
      text: 'Drag me!',
    ),
    NoteModel(
      id: '2',
      position: const Offset(80, 120),
      color: Colors.cyan,
      text: 'Tap to bring to front',
    ),
    NoteModel(
      id: '3',
      position: const Offset(150, 250),
      color: Colors.orange,
      text: 'Change my color',
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  void _bringToFront(String id) {
    setState(() {
      final note = _notes.firstWhere((n) => n.id == id);
      _notes.remove(note);
      _notes.add(note);
    });
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
  }

  void _editNote(NoteModel note) async {
    _controller.text = note.text;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(controller: _controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    setState(() {
      note.text = _controller.text;
    });
  }

  void _addNote() {
    setState(() {
      _notes.add(
        NoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          position: const Offset(40, 40),
          color: Colors.yellow,
          text: 'New note',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final stickyWidgets = _notes.map((note) {
      return StickyNote(
        key: ValueKey(note.id),
        id: note.id,
        size: const Size(120, 120),
        boardSize: boardSize,
        initialPosition: note.position,
        initialColor: note.color,
        availableColors: const [
          Colors.yellow,
          Colors.green,
          Colors.orange,
          Colors.cyan,
        ],

        // Keep widget in sync with external state
        syncWithInitialPosition: true,

        onPositionChanged: (pos) => note.position = pos,
        onColorChanged: (color) => note.color = color,
        onDelete: () => _deleteNote(note.id),
        onEdit: () => _editNote(note),
        onPanStart: () => _bringToFront(note.id),
        onTap: () => _bringToFront(note.id),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              note.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticky Notes Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add note',
            onPressed: _addNote,
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: boardSize.width,
          height: boardSize.height,
          color: Colors.grey.shade300,
          child: Stack(children: stickyWidgets),
        ),
      ),
    );
  }
}
