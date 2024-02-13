
STICKY_NOTES

## Features
Widget that puts its child in Sticky Note that can be moved in borders of its parent.

![Example notes containin Text, Icon and Image](https://github.com/mis177/sticky-notes/blob/main/image.png?raw=true) 



![Example usage](https://private-user-images.githubusercontent.com/56123042/304477872-67c7dbc8-e8b8-41dc-92a9-3590a2d66e7d.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDc4NDE0MjAsIm5iZiI6MTcwNzg0MTEyMCwicGF0aCI6Ii81NjEyMzA0Mi8zMDQ0Nzc4NzItNjdjN2RiYzgtZThiOC00MWRjLTkyYTktMzU5MGEyZDY2ZTdkLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAyMTMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMjEzVDE2MTg0MFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTk1ZmJhYzUzYThlZmJkODc2Y2E0ZTdkOWVjZDZhNTg0MTQ2YWU5ODgwOTVhMDJhNDcyMWVhNzFjZTM0YTk1ODAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.H2OxIPoG2AixA3VVic6JhFaSC2Hnt8Yku0F2t8Oye0s)


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
