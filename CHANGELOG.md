

## 1.0.0 - 2026-02-12

* **feat**: Initial stable release.
* **feat**: Add `StickyNote` widget with:
  - Drag & drop within parent bounds.
  - Interactive preview with `InteractiveViewer`.
  - Context menu with Edit, Color, Delete options.
  - Flexible child content support.
  - Callbacks for edit, color change, delete, and position change.
* **feat**: Optional `syncWithInitialPosition` to allow external control of note position.
* **test**: Added widget tests for rendering, dragging, color change, menu actions, and position sync.
* **docs**: Improved documentation and example usage.
* **breaking changes**: Consolidated old experimental features; API cleaned up for stable release.

## 0.4.0 - Legacy

* test!: Add unit and widget tests to package

## 0.3.0 - Legacy

* feat!: Add position property which shows current position (Offset) of the note (top left corner of parent is (0,0))

## 0.2.0 - Legacy

* docs: Add documentation to package.

## 0.1.2 - Legacy

* feat: Add optional `startingPosition` constructor parameter.
* feat: Add `onDragEnd` callback with current position argument (Offset).

## 0.0.1 - Legacy

* Initial release.
