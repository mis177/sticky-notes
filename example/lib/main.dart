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

  String note1 = 'Test Note 1';

  List<StickyNote> stickyNotes = [];
  List<GlobalKey<State<StatefulWidget>>> notesKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey()
  ];

  void setStickyNotes() {
    stickyNotes = [
      StickyNote(
        key: notesKeys[0],
        id: 1,
        width: 100,
        height: 100,
        // colors that will be displayed in Color menu when LongPress happens
        colorsEdit: const [
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.cyan
        ],
        // handle 'Edit' button event from LongPress menu, edit text
        onEdit: () async {
          notesTextController.text = note1;
          await showDialog(
              context: context,
              builder: ((context) {
                return AlertDialog(
                  title: const Text('Your note'),
                  icon: const Icon(Icons.note),
                  content: TextField(
                    controller: notesTextController,
                  ),
                );
              }));
          setState(() {
            note1 = notesTextController.text;
            setStickyNotes();
          });
        },
        // handle 'Delete' button event from LongPress menu, delete note from list
        onDelete: () {
          setState(() {
            onDeleteNote(1);
          });
        },
        child: Center(
          child: Text(
            note1,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      StickyNote(
        key: notesKeys[1],
        id: 2,
        width: 100,
        height: 100,
        colorsEdit: const [
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.cyan
        ],
        onDelete: () {
          setState(() {
            onDeleteNote(2);
          });
        },
        child: const FlutterLogo(
          size: 40,
        ),
      ),
      StickyNote(
        key: notesKeys[2],
        id: 3,
        width: 100,
        height: 100,
        colorsEdit: const [
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.cyan
        ],
        onDelete: () {
          setState(() {
            onDeleteNote(3);
          });
        },
        child: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/0/05/Cat.png',
          fit: BoxFit.fill,
        ),
      ),
    ];
  }

  @override
  void initState() {
    notesTextController = TextEditingController();
    // populate list of StickyNote with examples with text, Icon and Image
    setStickyNotes();
    super.initState();
  }

  @override
  void dispose() {
    notesTextController.dispose();
    super.dispose();
  }

  void onDeleteNote(int id) {
    setState(() {
      stickyNotes.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            color: Colors.green,
            height: 500,
            width: 300,
            child: Stack(
              children: stickyNotes,
            )),
      ),
    );
  }
}
