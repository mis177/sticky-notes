import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticky_notes/sticky_notes.dart';

void main() {
  late StickyNoteTest testWidget;
  setUpAll(() => testWidget = StickyNoteTest());
  testWidgets(
      'one StickyNote has a text "test note" as a child, other has Icon',
      (tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text('test note'), findsOneWidget);
  });

  testWidgets('test dragging note', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.drag(find.text('test note'), const Offset(100, 100));
    expect(testWidget.note.position, const Offset(100, 100));
  });

  testWidgets('test dragging note out of container bounds', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.drag(find.text('test note'), const Offset(1000, 1000));
    expect(testWidget.note.position, const Offset(500, 500));
  });

  testWidgets('test changing color', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.longPress(find.text('test note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Color'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
          (widget) => widget is Container && widget.color == Colors.orange),
    );

    expect(testWidget.note.color, Colors.orange);
  });

  testWidgets('test tap on note', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.text('test note'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('test delete note', (tester) async {
    await tester.pumpWidget(testWidget);

    await tester.longPress(find.text('test note'));
    await tester.pumpAndSettle();
    expect(find.text('test note'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('test note'), findsNothing);
  });
}

// ignore: must_be_immutable
class StickyNoteTest extends StatefulWidget {
  StickyNoteTest({
    super.key,
  });

  late StickyNote note;

  @override
  State<StickyNoteTest> createState() => _StickyNoteTestState();
}

class _StickyNoteTestState extends State<StickyNoteTest> {
  String noteText = 'test note';

  late StickyNote note = StickyNote(
    width: 100,
    height: 100,
    colorsEdit: const [Colors.green, Colors.yellow, Colors.orange, Colors.cyan],
    colorOptionName: 'Color',
    onDelete: () {
      setState(() {
        notes = [];
      });
    },
    child: Text(noteText),
  );

  late List<StickyNote> notes = [note];

  @override
  Widget build(BuildContext context) {
    widget.note = note;
    return MaterialApp(
      title: 'StickyNote Test',
      home: Scaffold(
        body: Container(
            color: Colors.green,
            height: 600,
            width: 600,
            child: Stack(
              children: notes,
            )),
      ),
    );
  }
}
