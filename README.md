STICKY_NOTES

A **draggable, interactive sticky note widget** for Flutter.
Place any widget inside a sticky note that can be moved, edited, color-changed, deleted, and previewed with zoom & pan.

---

## Features

* Drag & drop notes within a bounded container (`Stack`)
* Long press menu: Edit, Change color, Delete
* Tap to enlarge note with **InteractiveViewer** (zoom & pan)
* Flexible content (`child` can be any widget)
* Callbacks for editing, color changes, deletion, and position updates
* Persistent position sync with `syncWithInitialPosition` flag

---

## Demo

![advanced_example2](https://github.com/user-attachments/assets/24ca7d89-f90c-4278-ad55-e31d7fdbf5a2)



---

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  sticky_notes: ^1.0.0
```

Use `StickyNote` inside a `Stack`. The `Stack` bounds define the draggable area:

```dart
import 'package:flutter/material.dart';
import 'package:sticky_notes/sticky_notes.dart';

class StickyBoardExample extends StatefulWidget {
  const StickyBoardExample({super.key});

  @override
  State<StickyBoardExample> createState() => _StickyBoardExampleState();
}

class _StickyBoardExampleState extends State<StickyBoardExample> {
  String testNote = 'First note';
  final TextEditingController noteTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          height: 500,
          color: Colors.green[100],
          child: Stack(
            children: [
              StickyNote(
                id: '1',
                size: const Size(100, 100),
                initialPosition: const Offset(20, 20),
                initialColor: Colors.yellow,
                availableColors: const [
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.cyan,
                ],
                syncWithInitialPosition: true, // Enables external position updates
                onEdit: () async {
                  noteTextController.text = testNote;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit note'),
                      content: TextField(controller: noteTextController),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  setState(() {
                    testNote = noteTextController.text;
                  });
                },
                child: Center(
                  child: Text(
                    testNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Usage Notes

* **Drag & drop** notes within parent bounds
* **Long press** opens the menu with edit, color change, delete
* **Tap** opens a zoomable preview (`InteractiveViewer`)
* Any widget can be used as note content (`child`)
* Use `syncWithInitialPosition: true` to restore positions when notes are loaded from cache

---

## Contributing

This is my **first Flutter package**, so any feedback is appreciated.
Planned features:

* Persistent storage of notes
* Multi-board support
* More customizable UI
* Sticky notes board with some default options from example\lib\advanced_demo.dart

Contact: [jamroz.michal7@gmail.com](mailto:jamroz.michal7@gmail.com)

---

## License

MIT License
