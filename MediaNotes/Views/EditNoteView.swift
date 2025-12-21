import SwiftUI
import SwiftData

/// View for editing an existing note
/// ViewModel is always injected via init for testability
struct EditNoteView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: any EditNoteViewModelProtocol
    @FocusState private var isTextFocused: Bool
    
    private var timeProvider: TimeProvider {
        DependencyProvider.shared.dependencies.timeProvider
    }
    
    init(viewModel: any EditNoteViewModelProtocol) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.spacingLG) {
                    // Error message if any
                    if case .error(let message) = viewModel.formState {
                        errorBanner(message: message)
                    }
                    
                    // Media info (read-only)
                    if let media = viewModel.note.mediaItem {
                        mediaInfoSection(media)
                    }
                    
                    // Quote field
                    if viewModel.showQuoteField {
                        quoteSection
                    }
                    
                    // Note text
                    noteTextSection
                    
                    // Optional fields
                    if !viewModel.showQuoteField && (viewModel.note.quote == nil || viewModel.note.quote!.isEmpty) {
                        optionalFieldsToggle
                    }
                    
                    // Metadata
                    metadataSection
                }
                .padding(Theme.spacingMD)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
            .onAppear {
                isTextFocused = true
            }
        }
    }
    
    @ViewBuilder
    private var saveButton: some View {
        switch viewModel.formState {
        case .saving:
            ProgressView()
                .tint(viewModel.accentColor)
        default:
            Button("Save") {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.canSave ? viewModel.accentColor : Theme.textTertiary)
            .disabled(!viewModel.canSave)
        }
    }
    
    private func errorBanner(message: String) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(Theme.error)
            Text(message)
                .font(Theme.bodyFont(size: 14))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
        }
        .padding(Theme.spacingMD)
        .background(Theme.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSM))
    }
    
    // MARK: - Media Info Section
    
    private func mediaInfoSection(_ media: MediaItem) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("ATTACHED TO")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            HStack(spacing: Theme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(viewModel.accentColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: media.kind.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(viewModel.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(media.title)
                        .font(Theme.bodyFont(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                    
                    if let subtitle = media.displaySubtitle {
                        Text(subtitle)
                            .font(Theme.bodyFont(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMD)
                    .stroke(viewModel.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Quote Section
    
    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Text("QUOTE")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.toggleQuoteField()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            
            TextField("Enter a quote from the media...", text: $viewModel.editedQuote, axis: .vertical)
                .font(.system(size: 15, design: .serif))
                .italic()
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(3...6)
                .padding(Theme.spacingMD)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
                .overlay(
                    HStack {
                        Rectangle()
                            .fill(viewModel.accentColor.opacity(0.5))
                            .frame(width: 3)
                        Spacer()
                    }
                    .padding(.vertical, Theme.spacingSM)
                )
        }
    }
    
    // MARK: - Note Text Section
    
    private var noteTextSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("YOUR THOUGHTS")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            TextEditor(text: $viewModel.editedText)
                .font(Theme.bodyFont(size: 17))
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isTextFocused)
                .frame(minHeight: 200)
                .padding(Theme.spacingMD)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.border, lineWidth: 1)
                )
            
            HStack {
                Spacer()
                Text("\(viewModel.characterCount) characters")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }
    
    // MARK: - Optional Fields
    
    private var optionalFieldsToggle: some View {
        HStack {
            Button {
                withAnimation {
                    viewModel.toggleQuoteField()
                }
            } label: {
                Label("Add Quote", systemImage: "quote.opening")
                    .font(Theme.bodyFont(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(GhostButtonStyle())
            
            Spacer()
        }
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("INFO")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            VStack(spacing: Theme.spacingSM) {
                HStack {
                    Text("Created")
                        .font(Theme.bodyFont(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text(viewModel.note.formattedDate(relativeTo: timeProvider.now))
                        .font(Theme.monoFont(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                }
                
                if let editedAt = viewModel.note.editedAt {
                    HStack {
                        Text("Last edited")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text(formatDate(editedAt, relativeTo: timeProvider.now))
                            .font(Theme.monoFont(size: 13))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }
            .padding(Theme.spacingMD)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date, relativeTo referenceDate: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(date, inSameDayAs: referenceDate) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Today, \(formatter.string(from: date))"
        } else if Calendar.current.isDate(date, inSameDayAs: referenceDate.addingTimeInterval(-86400)) {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

#Preview {
    let schema = Schema([MediaItem.self, Note.self, MediaAttribute.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let dependencies = DependencyContainer(modelContainer: container)
    
    // Initialize DependencyProvider for preview
    DependencyProvider.shared.initialize(container: dependencies)
    
    let mediaItem = MediaItem(title: "Breaking Bad", kind: .tvSeries)
    let note = Note(text: "This is a test note with some content that can be edited.", mediaItem: mediaItem)
    return dependencies.makeEditNoteView(note: note)
}
