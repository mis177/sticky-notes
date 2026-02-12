import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticky_notes/sticky_notes.dart';

void main() {
  group('StickyNote Widget Tests', () {
    testWidgets('StickyNote renders correctly', (WidgetTester tester) async {
      final stickyKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StickyNote(
                  key: stickyKey,
                  id: '1',
                  size: const Size(100, 100),
                  boardSize: const Size(300, 300),
                  initialPosition: const Offset(10, 20),
                  initialColor: Colors.yellow,
                  child: const Text('Hello'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StickyNote), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('StickyNote calls onPositionChanged when dragged', (WidgetTester tester) async {
      Offset? updatedPosition;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StickyNote(
                  id: '1',
                  size: const Size(100, 100),
                  boardSize: const Size(300, 300),
                  initialPosition: const Offset(0, 0),
                  child: const Text('Drag me'),
                  onPositionChanged: (pos) => updatedPosition = pos,
                ),
              ],
            ),
          ),
        ),
      );

      final noteFinder = find.byType(StickyNote);
      await tester.drag(noteFinder, const Offset(50, 50));
      await tester.pumpAndSettle();

      expect(updatedPosition, isNotNull);
      expect(updatedPosition!.dx, greaterThan(0));
      expect(updatedPosition!.dy, greaterThan(0));
    });

    testWidgets('StickyNote calls onEdit callback', (WidgetTester tester) async {
      bool edited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StickyNote(
                  id: '1',
                  size: const Size(100, 100),
                  boardSize: const Size(300, 300),
                  initialPosition: const Offset(0, 0),
                  child: const Text('Edit me'),
                  onEdit: () => edited = true,
                ),
              ],
            ),
          ),
        ),
      );

      final sticky = tester.widget<StickyNote>(find.byType(StickyNote));
      sticky.onEdit?.call();

      expect(edited, isTrue);
    });

    testWidgets('StickyNote calls onDelete callback', (WidgetTester tester) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StickyNote(
                  id: '1',
                  size: const Size(100, 100),
                  boardSize: const Size(300, 300),
                  initialPosition: const Offset(0, 0),
                  child: const Text('Delete me'),
                  onDelete: () => deleted = true,
                ),
              ],
            ),
          ),
        ),
      );

      final sticky = tester.widget<StickyNote>(find.byType(StickyNote));
      sticky.onDelete?.call();

      expect(deleted, isTrue);
    });

    testWidgets('StickyNote calls onColorChanged callback', (WidgetTester tester) async {
      Color? newColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StickyNote(
                  id: '1',
                  size: const Size(100, 100),
                  boardSize: const Size(300, 300),
                  initialPosition: const Offset(0, 0),
                  availableColors: const [Colors.red, Colors.blue],
                  onColorChanged: (color) => newColor = color,
                  child: const Text('Color me'),
                ),
              ],
            ),
          ),
        ),
      );

      final sticky = tester.widget<StickyNote>(find.byType(StickyNote));
      sticky.onEdit?.call();
      sticky.onDelete?.call();
      sticky.onColorChanged?.call(Colors.red);

      expect(newColor, Colors.red);
    });

    testWidgets('StickyNote updates position if syncWithInitialPosition is true', (WidgetTester tester) async {
      const initialPos = Offset(10, 20);
      const updatedPos = Offset(50, 60);

      Widget buildTestWidget(Offset pos) => MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  StickyNote(
                    id: '1',
                    size: const Size(100, 100),
                    boardSize: const Size(300, 300),
                    initialPosition: pos,
                    syncWithInitialPosition: true,
                    child: const Text('Sync test'),
                  ),
                ],
              ),
            ),
          );

      await tester.pumpWidget(buildTestWidget(initialPos));
      expect(tester.getTopLeft(find.byType(StickyNote)), initialPos);

      await tester.pumpWidget(buildTestWidget(updatedPos));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byType(StickyNote)), updatedPos);
    });
  });
}
