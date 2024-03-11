
STICKY_NOTES

## Features
Widget that puts its child in Sticky Note that can be moved in borders of its parent.


Running Example code:




![usage](https://github.com/mis177/sticky-notes/assets/56123042/91bb434a-a5d5-4bb7-8fbd-8416e13a746c)



## Getting started

Add package to your project.
Create and place StickyNotes objects inside Stack Widget. Bounds of that Stack are bounds of Sticky Notes.


## Usage

Retruns draggable (inside parent Container) sticky note. Long press shows menu with default edit, color change and delete options. Single Tap makes note bigger and provides InteractiveViewer to its child (enables zooming and panning). 
```dart
 @override
  Widget build(BuildContext context) {   
    String testNote = 'First test note';
    TextEditingController noteTextController = TextEditingController();
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.green,
          height: 500,
          width: 300,
          child: Stack(
              children: [
                StickyNote(
                  width: 100,
                  height: 100,
                  colorsEdit: const [
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.cyan
                  ],
                  onEdit: () async {
                    notesTextController.text = testNote;
                    await showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text('Your note'),
                            icon: const Icon(Icons.note),
                            content: TextField(
                              controller: noteTextController,
                            ),
                          );
                        }));
                    setState(() {
                      testNote = noteTextController.text;
                    });
                  },
                  child: Center(
                    child: Text(
                      testNote,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
```

## Additional information

It is my first package so any feedback is appreciated. It is first version, updates coming soon.
Contact: jamroz.michal7@gmail.com
