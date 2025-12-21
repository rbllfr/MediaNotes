# Snapshot Tests

This directory contains snapshot tests for all views in the MediaNotes application.

## What's Been Created

All snapshot test files have been filled with comprehensive test cases:

1. **SnapshotTestHelpers.swift** - Common utilities and sample data factories for snapshot testing
2. **ThemeSnapshotTests.swift** - Tests for theme colors, typography, and button styles (6 tests)
3. **MediaRowViewSnapshotTests.swift** - Tests for media row components across all media kinds (20 tests)
4. **NoteRowViewSnapshotTests.swift** - Tests for note row components with various configurations (13 tests)
5. **ContentViewSnapshotTests.swift** - Tests for main tab view container (7 tests)
6. **LibraryViewSnapshotTests.swift** - Tests for library view in different states (7 tests)
7. **SearchViewSnapshotTests.swift** - Tests for search view with various result states (5 tests)
8. **AddNoteViewSnapshotTests.swift** - Tests for add note view with different media types (8 tests)
9. **EditNoteViewSnapshotTests.swift** - Tests for edit note view (6 tests)
10. **MediaDetailViewSnapshotTests.swift** - Tests for media detail view with hierarchical content (8 tests)
11. **SelectMediaViewSnapshotTests.swift** - Tests for media selection view (6 tests)
12. **AddMediaViewSnapshotTests.swift** - Tests for add media view across media types (9 tests)

## Prerequisites

### SnapshotTesting Framework

The tests require the [PointFree SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) framework.

If not already added, add it to your project:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the URL: `https://github.com/pointfreeco/swift-snapshot-testing`
3. Select the latest version
4. Add it to the **MediaNotesTests** target

## Running the Tests

### First Time Setup

When running snapshot tests for the first time:

1. Change `record: .missing` to `record: .all` in the test's `invokeTest()` method
2. Run the tests - this will generate reference snapshots
3. Change it back to `record: .missing`
4. Run the tests again - they will now compare against the reference snapshots

**Recording Modes:**
- `.missing` - Only record snapshots that don't exist (recommended default)
- `.all` - Re-record all snapshots
- `.never` - Never record, only compare (for CI)

### Regular Test Runs

Once reference snapshots are recorded, simply run the tests normally. They will fail if the UI has changed unexpectedly.

### Updating Snapshots

If you intentionally change the UI:

**Option 1: Re-record specific tests**
1. Change `record: .missing` to `record: .all` in the specific test file
2. Run the tests to regenerate snapshots
3. Change it back to `record: .missing`
4. Commit the new snapshots to git

**Option 2: Delete and re-record**
1. Delete the old snapshots from `__Snapshots__/[TestClassName]/`
2. Run the tests (with `record: .missing`) to regenerate missing snapshots
3. Commit the new snapshots to git

## Test Coverage

The snapshot tests cover:

- ✅ All view components (MediaRowView, NoteRowView)
- ✅ All main screens (Library, Search, ContentView)
- ✅ All form screens (AddNote, EditNote, AddMedia, SelectMedia)
- ✅ Detail views (MediaDetail)
- ✅ Theme components (colors, typography, buttons)
- ✅ Different states (empty, loading, error, ready with data)
- ✅ Different media types (Movie, TV Series, Book, Album, Live Event)
- ✅ Hierarchical content (TV series with episodes, books with chapters)
- ✅ Various device sizes and configurations

## Mock View Models

All tests use mock view models located in `MediaNotesTests/Mocks/`:

- `MockLibraryViewModel`
- `MockSearchViewModel`
- `MockAddNoteViewModel`
- `MockEditNoteViewModel`
- `MockMediaDetailViewModel`
- `MockSelectMediaViewModel`
- `MockAddMediaViewModel` (newly created)

These mocks allow testing views in isolation without requiring a full SwiftData stack.

## Notes

- Tests use dark mode by default (matches app's aesthetic)
- Standard device size is iPhone (375pt width) unless testing specific device sizes
- All tests initialize `DependencyProvider` with a `MockDependencyContainer` for isolation
- Snapshot images are stored in `__Snapshots__/[TestClassName]/` directories

