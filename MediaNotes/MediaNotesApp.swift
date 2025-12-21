import SwiftUI
import SwiftData

@main
struct MediaNotesApp: App {
    let sharedModelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            MediaItem.self,
            Note.self,
            MediaAttribute.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            
            // Initialize dependency provider
            let dependencyContainer = DependencyContainer(modelContainer: container)
            DependencyProvider.shared.initialize(container: dependencyContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
               // .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
