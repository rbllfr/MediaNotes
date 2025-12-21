import SwiftUI
import SwiftData

/// Main tab-based navigation container
struct ContentView: View {

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                Tab("Library", systemImage: "books.vertical") {
                    DependencyProvider.shared.dependencies.makeLibraryView()
                }
                
                Tab("Media", systemImage: "square.stack.3d.up") {
                    DependencyProvider.shared.dependencies.makeMediaListView()
                }
                
                Tab("Insights", systemImage: "sparkles") {
                    DependencyProvider.shared.dependencies.makeInsightsView(mediaItem: nil)
                }
                
                Tab("Search", systemImage: "magnifyingglass") {
                    DependencyProvider.shared.dependencies.makeSearchView()
                }
            }
        }
    }
    
}

#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    let mediaRepository = SwiftDataMediaRepository.init(modelContext: container.mainContext)
    let noteRepository = SwiftDataNoteRepository.init(modelContext: container.mainContext)
    
    Task {
        let mediaItem = MediaItem(title: "Stub moview", kind: .movie)
        try? await mediaRepository.save(mediaItem)
        _ = try? await noteRepository.create(text: "Stub note", for: mediaItem)
    }

    
    // Initialize DependencyProvider for preview
    DependencyProvider.shared.initialize(container: dependencies)
    
    return ContentView()
        .modelContainer(container)
}




