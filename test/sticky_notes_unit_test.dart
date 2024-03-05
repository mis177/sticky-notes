import 'package:flutter/material.dart';
import 'package:sticky_notes/sticky_notes.dart';
import 'package:test/test.dart';

void main() {
  late StickyNote note;
  String noteText = 'test note';
  setUp(() {
    note = StickyNote(
      width: 100,
      height: 100,
      startingPosition: const Offset(100, 200),
      colorsEdit: const [
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.cyan
      ],
      onEdit: () async {
        noteText = 'changed text';
      },
      child: Text(noteText),
    );
  });
  group('Starting parameters', () {
    test('Note is type of StickyNote', () {
      expect(note.runtimeType, StickyNote);
    });

    test('Note has starting position set by startingPosition argument', () {
      expect(note.position, const Offset(100, 200));
    });
  });
}
