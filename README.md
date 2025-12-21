# Media Notes

A private iOS app for attaching personal notes to media you consume — TV shows, episodes, movies, books, music, and live events.

## Features

### v1.0 - Core Features

- **📝 Add Notes**: Create free-form text notes attached to any media item
- **📚 Media Library**: View all media items that have notes attached
- **✨ Insights**: AI-powered analysis of your notes to discover patterns, preferences, and get personalized recommendations using Apple Intelligence
- **🔍 Search**: Search by media title or note content
- **🎬 Media Types**: Support for movies, TV series, episodes, books, chapters, albums, tracks, live events, and performances
- **📊 Hierarchical Structure**: Media items can have parent-child relationships (series → episodes, albums → tracks)
- **✏️ Edit & Delete**: Full control over your notes

### Design Philosophy

- **Raw user data is sacred** — Notes are always shown unmodified and unaltered
- **Privacy-first** — All data stays on-device; optional AI features use Apple Intelligence (no third-party APIs)
- **Optional AI enhancement** — Insights are opt-in; core note-taking works without AI
- **Generic & extensible** — Data model scales to unknown media types
- **Trust & clarity** — Full transparency in how your data is used

## Requirements

- iOS 17.0+ (iOS 18.2+ for Insights feature with Apple Intelligence)
- Xcode 16.0+
- Swift 6.0+

## Project Structure

```
MediaNotes/
├── MediaNotesApp.swift          # App entry point with SwiftData container
├── Models/                      # Data models (SwiftData)
│   ├── MediaItem.swift          # Core media item model (hierarchical)
│   ├── Note.swift               # User note/thought model
│   ├── MediaAttribute.swift     # Flexible key-value metadata
│   ├── MediaKind.swift          # Media type enum
│   └── MediaAttributeKey.swift  # Type-safe attribute keys
├── Services/                    # Business logic & data access
│   ├── DependencyContainer.swift     # Central dependency injection
│   ├── DependencyContaining.swift    # DI protocol
│   ├── TimeProvider.swift            # Injectable time service
│   ├── InsightsProvider.swift        # AI-powered insights generation
│   └── Repositories/
│       ├── MediaRepository.swift     # Media data access layer
│       └── NoteRepository.swift      # Note data access layer
├── ViewModels/                  # Presentation logic (MVVM)
│   ├── LibraryViewModel.swift        # Library screen logic
│   ├── InsightsViewModel.swift       # Insights generation logic
│   ├── SearchViewModel.swift         # Search screen logic
│   ├── AddNoteViewModel.swift        # Add note form logic
│   ├── EditNoteViewModel.swift       # Edit note form logic
│   ├── MediaDetailViewModel.swift    # Media detail screen logic
│   ├── SelectMediaViewModel.swift    # Media picker logic
│   ├── AddMediaViewModel.swift       # Add media form logic
│   ├── ViewState.swift               # Common view state enum
│   └── FormState.swift               # Common form state enum
├── Views/                       # SwiftUI views
│   ├── ContentView.swift        # Tab-based navigation container
│   ├── LibraryView.swift        # Home screen with media library
│   ├── InsightsView.swift       # AI-powered insights and recommendations
│   ├── MediaDetailView.swift    # Media item detail with notes
│   ├── AddNoteView.swift        # Create new note flow
│   ├── EditNoteView.swift       # Edit existing note
│   ├── SearchView.swift         # Search media and notes
│   ├── SelectMediaView.swift    # Media picker for note attachment
│   ├── AddMediaView.swift       # Create new media item
│   ├── MediaRowView.swift       # Media item list row component
│   ├── NoteRowView.swift        # Note list row component
│   ├── MediaHierarchyView.swift # Child media management
│   └── Theme.swift              # App-wide styling
└── Assets.xcassets/             # Colors and images

MediaNotesTests/
├── ViewModels/                  # Unit tests for ViewModels
├── Snapshots/                   # Snapshot tests for Views
│   └── __Snapshots__/           # Reference images
└── Mocks/                       # Test doubles & fixtures
```

## Architecture

### Design Pattern: MVVM + Repository

The app follows a clean architecture with clear separation of concerns:

```
View ← ViewModel ← Repository ← SwiftData
  ↑         ↑           ↑
  └─────────┴───────────┴──── DependencyContainer
```

#### Layers

**Views (SwiftUI)**
- Stateless, declarative UI components
- Observe ViewModels via `@ObservedObject` or `@StateObject`
- Handle user interactions by calling ViewModel methods
- No direct access to data layer or business logic

**ViewModels**
- Manage presentation logic and view state
- Expose `@Published` properties for views to observe
- Coordinate between repositories
- Handle async operations and error states
- Testable without UI dependencies

**Repositories**
- Abstract data access behind protocols (`MediaRepositoryProtocol`, `NoteRepositoryProtocol`)
- Provide clean API for CRUD operations
- Encapsulate SwiftData queries and persistence
- Enable testing with mock implementations

**Models (SwiftData)**
- Pure data models with `@Model` macro
- Define relationships and validation rules
- No business logic or presentation concerns

**Services (InsightsProvider)**
- Uses Apple's FoundationModels framework for on-device AI
- Analyzes user notes to generate insights and recommendations
- Protocol-based design enables testability with mock implementations
- Checks device compatibility and Apple Intelligence availability

#### Dependency Injection

**DependencyContainer**
- Central factory for creating views with their dependencies
- Manages shared resources (ModelContext, TimeProvider)
- Injects repositories into ViewModels
- Enables test isolation by swapping implementations

**Benefits:**
- Views and ViewModels are easily testable with mocks
- No singleton dependencies or global state
- Clear dependency graph
- Simple to add new features without breaking existing code

#### State Management

**ViewState Enum**
```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}
```
Used consistently across ViewModels to represent async data loading states.

**FormState Enum**
```swift
enum FormState {
    case idle
    case submitting
    case success
    case error(String)
}
```
Used for form submission states (add/edit flows).

## Data Model

### MediaItem
Represents any media the user can attach notes to:
- `id`, `title`, `kind`, `subtitle`, `artworkURL`
- `sortKey` for ordering children
- `parent` / `children` for hierarchy
- `notes` relationship
- `attributes` for flexible metadata

### Note
Represents a user's thought or reflection:
- `id`, `text`, `createdAt`, `editedAt`
- `quote` (optional) for referencing media
- `timeOffset` (optional) for video/audio timestamps
- `mediaItem` relationship (required)

### MediaAttribute
Flexible key-value metadata:
- Namespaced keys (e.g., `tv.seasonNumber`, `book.author`)
- Type-safe access via `MediaAttributeKey`
- Unlimited extension without schema changes

## Insights Feature

The Insights feature uses **Apple Intelligence** (FoundationModels framework) to analyze your notes and provide personalized recommendations.

### How It Works

1. **On-Device Processing**: All analysis happens locally using Apple's SystemLanguageModel
2. **Note Analysis**: The AI reviews your notes across all media types to identify patterns
3. **Generated Output**:
   - **Summary**: Overview of your media consumption preferences
   - **Analysis**: Detailed breakdown of patterns in your notes
   - **Recommendations**: Personalized suggestions for new media to explore

### Privacy & Requirements

- **100% On-Device**: No data leaves your device
- **Opt-In**: Insights are only generated when you request them
- **Requirements**:
  - iOS 18.2 or later
  - Apple Intelligence enabled
  - Compatible device (iPhone 15 Pro or later, iPad with M1+, or Mac with Apple Silicon)
  
### Availability Handling

The app gracefully handles cases where Apple Intelligence is unavailable:
- Device not compatible
- Apple Intelligence not enabled
- Model not ready

Users on older devices or iOS versions can still use all core note-taking features.

## Building

1. Open `MediaNotes.xcodeproj` in Xcode 15+
2. Select your target device or simulator
3. Build and run (⌘R)

## Testing Strategy

The app uses a comprehensive testing strategy to ensure reliability and maintainability:

### Test Types

#### 1. Unit Tests (ViewModels)
**Location:** `MediaNotesTests/ViewModels/`

- Test business logic and state management in isolation
- Mock repositories to avoid database dependencies
- Verify async operations, error handling, and state transitions
- Use `FixedTimeProvider` for deterministic date/time testing

**Example Tests:**
- `AddNoteViewModelTests`: Form validation, note creation, error handling
- `LibraryViewModelTests`: Media loading, sorting, empty states
- `InsightsViewModelTests`: Model availability checking, insights generation, error handling
- `SearchViewModelTests`: Search logic, debouncing, result filtering

**Coverage:** All ViewModels have corresponding test files with 90%+ code coverage.

#### 2. Snapshot Tests (Views)
**Location:** `MediaNotesTests/Snapshots/`
**Framework:** [PointFree SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)

- Capture reference images of UI components
- Detect unintended visual regressions
- Test different states (empty, loading, error, populated)
- Test across media types and device sizes

**Example Tests:**
- `MediaRowViewSnapshotTests`: All media kinds (movie, TV, book, album, event)
- `LibraryViewSnapshotTests`: Empty state, loading, populated library
- `InsightsViewSnapshotTests`: Empty, loading, insights generated, unavailable states
- `ThemeSnapshotTests`: Colors, typography, button styles

**Coverage:** 12 snapshot test suites covering all major views and components (~100 snapshots total).

#### 3. Mock Objects
**Location:** `MediaNotesTests/Mocks/`

Clean, reusable test doubles for dependency injection:

- `MockMediaRepository` / `MockNoteRepository`: In-memory data stores
- `MockInsightsProvider`: Simulates Apple Intelligence responses
- `MockDependencyContainer`: Test-friendly dependency injection
- `MockViewModels`: Pre-configured view models for snapshot tests
- `FixedTimeProvider`: Deterministic time for tests

### Testing Principles

**1. Testability by Design**
- Protocol-oriented repositories enable easy mocking
- Dependency injection at all levels (no singletons)
- Pure ViewModels with no SwiftUI dependencies
- Injectable time provider for deterministic date testing

**2. Test Pyramid**
```
     /\
    /  \    Snapshot Tests (UI validation)
   /────\
  /      \  Unit Tests (business logic)
 /________\
```
- More unit tests than snapshot tests
- Fast, deterministic, independent tests
- Tests run in isolation without side effects

**3. Continuous Integration Ready**
- All tests run via `xcodebuild test`
- No manual setup or external dependencies
- Snapshot tests use `.missing` mode to prevent accidental re-recording
- Test plans: `MediaNotes.xctestplan` and `MediaNotesTests.xctestplan`

### Running Tests

**Run all tests:**
```bash
xcodebuild test -project MediaNotes.xcodeproj -scheme MediaNotes -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run specific test suite:**
```bash
# Unit tests only
xcodebuild test -project MediaNotes.xcodeproj -scheme MediaNotes -testPlan MediaNotesTests

# In Xcode: ⌘U (run all tests) or click the diamond next to a test
```

**Update snapshot tests:**
1. Change `record: .missing` to `record: .all` in the test file
2. Run the tests to regenerate snapshots
3. Change back to `record: .missing`
4. Commit the new snapshot images

### Test Coverage Goals

- **ViewModels:** 90%+ code coverage (business logic)
- **Views:** Visual regression coverage via snapshots
- **Repositories:** Tested indirectly through ViewModel tests
- **Models:** Tested indirectly through integration tests

## Future Roadmap

- **v1.x**: User-defined tags for notes and filtering
- **v1.x**: Export notes and insights to markdown or PDF
- **v2.0**: Enhanced insights with trend tracking over time
- **v2.x**: Reflection prompts based on consumption patterns

## License

Private project - All rights reserved




