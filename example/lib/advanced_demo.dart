import 'package:flutter/material.dart';
import 'package:sticky_notes/sticky_notes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StickyNotesTest(),
    );
  }
}

class StickyNotesTest extends StatefulWidget {
  const StickyNotesTest({super.key});

  @override
  State<StickyNotesTest> createState() => _StickyNotesTestState();
}

class _StickyNotesTestState extends State<StickyNotesTest> {
  late TextEditingController notesTextController;

  List<Map<String, dynamic>> notesData = [];
  List<String> notesOrder = [];

  final Size boardSize = const Size(300, 500);

  Map<String, Map<String, dynamic>> cachedNotes = {};

  @override
  void initState() {
    super.initState();
    notesTextController = TextEditingController();

    notesData = [
      {
        'id': '1',
        'child': 'Test Note 1',
        'color': Colors.yellow,
        'position': const Offset(10, 10),
      },
      {
        'id': '2',
        'child': const FlutterLogo(size: 40),
        'color': Colors.cyan,
        'position': const Offset(50, 50),
      },
      {
        'id': '3',
        'child': Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/0/05/Cat.png',
          fit: BoxFit.cover,
        ),
        'color': Colors.orange,
        'position': const Offset(100, 150),
      },
    ];

    notesOrder = notesData.map((e) => e['id'] as String).toList();
  }

  @override
  void dispose() {
    notesTextController.dispose();
    super.dispose();
  }

  void bringNoteToFront(String id) {
    setState(() {
      notesOrder.remove(id);
      notesOrder.add(id);
    });
  }

  void updateNotePosition(String id, Offset pos) {
    final note = notesData.firstWhere((n) => n['id'] == id);
    note['position'] = pos;
  }

  void updateNoteColor(String id, Color color) {
    final note = notesData.firstWhere((n) => n['id'] == id);
    note['color'] = color;
  }

  void deleteNote(String id) {
    setState(() {
      notesData.removeWhere((n) => n['id'] == id);
      notesOrder.remove(id);
    });
  }

  void editNote(String id) async {
    final note = notesData.firstWhere((n) => n['id'] == id);

    if (note['child'] is String) {
      notesTextController.text = note['child'] as String;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(controller: notesTextController),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      setState(() {
        note['child'] = notesTextController.text;
      });
    } else if (note['child'] is Image) {
      // TODO implement image editing
    }
  }

  void addNewNote() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      notesData.add({
        'id': id,
        'child': 'New Note',
        'color': Colors.yellow,
        'position': const Offset(20, 20),
      });
      notesOrder.add(id);
    });
  }

  void saveNotesToCache() {
    cachedNotes = {
      for (var note in notesData)
        note['id'] as String: {
          'type': note['child'] is String
              ? 'text'
              : note['child'] is Image
                  ? 'image'
                  : 'flutterlogo',
          'data': note['child'] is String
              ? note['child']
              : note['child'] is Image
                  ? (note['child'] as Image).image is NetworkImage
                      ? ((note['child'] as Image).image as NetworkImage).url
                      : null
                  : null,
          'color': (note['color'] as Color).toARGB32(),
          'position': {
            'dx': (note['position'] as Offset).dx,
            'dy': (note['position'] as Offset).dy,
          },
        }
    };
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes saved to cache!')),
    );
  }

  void loadNotesFromCache() {
    if (cachedNotes.isEmpty) return;

    setState(() {
      notesData = cachedNotes.entries.map((e) {
        final val = e.value;
        final posMap = val['position'] as Map<String, dynamic>;
        final pos = Offset(posMap['dx'], posMap['dy']);
        final color = Color(val['color'] as int);
        late dynamic child;
        switch (val['type'] as String) {
          case 'text':
            child = val['data'] as String;
            break;
          case 'image':
            if (val['data'] != null) {
              child = Image.network(val['data'] as String, fit: BoxFit.cover);
            } else {
              child = const FlutterLogo(size: 40);
            }
            break;
          case 'flutterlogo':
          default:
            child = const FlutterLogo(size: 40);
        }

        return {
          'id': e.key,
          'child': child,
          'color': color,
          'position': pos,
        };
      }).toList();

      notesOrder = notesData.map((e) => e['id'] as String).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes loaded from cache!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stickyNotes = notesOrder.map((id) {
      final data = notesData.firstWhere((n) => n['id'] == id);
      final childWidget = data['child'] is String
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['child'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
              ),
            )
          : data['child'] as Widget;

      final previewChildWidget = data['child'] is String
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Text(
                    data['child'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            )
          : null;
      return StickyNote(
        key: ValueKey(id),
        id: id,
        size: const Size(100, 100),
        boardSize: boardSize,
        previewChild: previewChildWidget,
        initialPosition: data['position'],
        initialColor: data['color'],
        availableColors: const [Colors.green, Colors.yellow, Colors.orange, Colors.cyan],
        // Enable external position synchronization (e.g. after restoring from cache)
        syncWithInitialPosition: true,
        onPositionChanged: (pos) => updateNotePosition(id, pos),
        onColorChanged: (color) => updateNoteColor(id, color),
        onDelete: () => deleteNote(id),
        onEdit: () => editNote(id),
        onPanStart: () => bringNoteToFront(id),
        onTap: () => bringNoteToFront(id),
        child: childWidget,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sticky Notes Test'),
        actions: [
          IconButton(
            onPressed: addNewNote,
            icon: const Icon(Icons.add),
            tooltip: 'Add new note',
          ),
          IconButton(
            onPressed: saveNotesToCache,
            icon: const Icon(Icons.save),
            tooltip: 'Save notes to cache',
          ),
          IconButton(
            onPressed: loadNotesFromCache,
            icon: const Icon(Icons.restore),
            tooltip: 'Load notes from cache',
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.grey[300],
          width: boardSize.width,
          height: boardSize.height,
          child: Stack(children: stickyNotes),
        ),
      ),
    );
  }
}
