import SwiftUI
import SwiftData
import FoundationModels

struct InsightsView: View {
    
    let viewModel: any InsightsViewModelProtocol
    
    init(viewModel: any InsightsViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                if let unavailabilityReason = viewModel.unavailabilityReason {
                    unavailableView(reason: unavailabilityReason)
                } else {
                    contentView
                }
            }
            .navigationTitle(viewModel.navigationTitle)
        }
        .task {
            await viewModel.initialize()
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .empty:
            emptyView
        case .loading:
            loadingView
        case .ready(let insights):
            insightsView(insights: insights)
        case .error(let message):
            errorView(message: message)
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: Theme.spacingLG) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
            
            Text("Generate Insights")
                .font(Theme.headingFont(size: 28))
                .foregroundStyle(Theme.textPrimary)
            
            Text(viewModel.emptyStateMessage)
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingXL)
            
            Button {
                Task {
                    await viewModel.generateInsights()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Insights")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.spacingSM)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: Theme.spacingMD) {
            ProgressView()
                .tint(Theme.accent)
                .scaleEffect(1.5)
            
            Text("Generating insights...")
                .font(Theme.headingFont(size: 20))
                .foregroundStyle(Theme.textSecondary)
        }
    }
    
    // MARK: - Insights View
    
    private func insightsView(insights: Insights) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                // Summary Card
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Summary")
                        .font(Theme.headingFont(size: 20))
                        .foregroundStyle(Theme.accent)
                    
                    Text(insights.summary)
                        .font(Theme.bodyFont(size: 18))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.spacingMD)
                .themedCard()
                
                // Rationale Card
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    Text("Analysis")
                        .font(Theme.headingFont(size: 20))
                        .foregroundStyle(Theme.accent)
                    
                    Text(insights.rationale)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.spacingMD)
                .themedCard()
                
                // Recommendations Card
                VStack(alignment: .leading, spacing: Theme.spacingSM) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Theme.accent)
                        Text("Recommendations")
                            .font(Theme.headingFont(size: 20))
                            .foregroundStyle(Theme.accent)
                    }
                    
                    Text(insights.recommendations)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.spacingMD)
                .themedCard()
                
                // Refresh Button
                Button {
                    Task {
                        await viewModel.generateInsights()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate Insights")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.top, Theme.spacingSM)
            }
            .padding(Theme.spacingMD)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.error)
            
            Text("Failed to Generate Insights")
                .font(Theme.headingFont(size: 24))
                .foregroundStyle(Theme.textPrimary)
            
            Text(message)
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingLG)
            
            Button {
                Task {
                    await viewModel.generateInsights()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, Theme.spacingSM)
        }
    }
    
    // MARK: - Unavailable View
    
    private func unavailableView(reason: String) -> some View {
        VStack(spacing: Theme.spacingMD) {
            Image(systemName: "brain")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary)
            
            Text("Insights Unavailable")
                .font(Theme.headingFont(size: 24))
                .foregroundStyle(Theme.textPrimary)
            
            Text(reason)
                .font(Theme.bodyFont(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingLG)
        }
    }
}

#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    let noteRepository = SwiftDataNoteRepository.init(modelContext: container.mainContext)
    
    let provider = FoundationModelsInsightsProvider(noteRepository: noteRepository)
    let viewModel = InsightsViewModel(insightsProvider: provider)
    InsightsView(viewModel: viewModel)
}
