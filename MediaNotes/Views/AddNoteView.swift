import SwiftUI
import SwiftData

/// Full-screen view for adding a new note
/// ViewModel is always injected via init for testability
struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: any AddNoteViewModelProtocol
    @State private var showingMediaPicker = false
    @FocusState private var isNoteFieldFocused: Bool
    
    init(viewModel: any AddNoteViewModelProtocol) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .background(Theme.background.ignoresSafeArea())
                .navigationTitle("New Note")
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
                .sheet(isPresented: $showingMediaPicker) {
                    DependencyProvider.shared.dependencies.makeSelectMediaView(
                        selectedMedia: Binding(
                            get: { viewModel.selectedMedia },
                            set: { if let media = $0 { viewModel.selectMedia(media) } }
                        )
                    )
                }
        }
        .onAppear {
            isNoteFieldFocused = true
        }
    }
    
    @ViewBuilder
    private var saveButton: some View {
        switch viewModel.formState {
        case .saving:
            ProgressView()
                .tint(Theme.accent)
        default:
            Button("Save") {
                Task {
                    if await viewModel.save() {
                        dismiss()
                    }
                }
            }
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.canSave ? Theme.accent : Theme.textTertiary)
            .disabled(!viewModel.canSave)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                // Error message if any
                if case .error(let message) = viewModel.formState {
                    errorBanner(message: message)
                }
                
                mediaSelectionSection
                
                if viewModel.showQuoteField {
                    quoteSection
                }
                
                noteTextSection
                optionalFieldsToggle
            }
            .padding(Theme.spacingMD)
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
    
    // MARK: - Media Selection Section
    
    private var mediaSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            Text("ATTACHED TO")
                .font(Theme.monoFont(size: 11))
                .foregroundStyle(Theme.textTertiary)
            
            Button {
                showingMediaPicker = true
            } label: {
                HStack(spacing: Theme.spacingMD) {
                    if let media = viewModel.selectedMedia {
                        ZStack {
                            Circle()
                                .fill(Theme.color(for: media.kind).opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: media.kind.iconName)
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.color(for: media.kind))
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
                        
                        Text("Change")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundStyle(Theme.accent)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Theme.secondaryBackground)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.textTertiary)
                        }
                        
                        Text("Select Media")
                            .font(Theme.bodyFont(size: 16))
                            .foregroundStyle(Theme.textSecondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
                .padding(Theme.spacingMD)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(
                            viewModel.selectedMedia != nil ? Theme.color(for: viewModel.selectedMedia!.kind).opacity(0.3) : Theme.border,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
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
                    viewModel.toggleQuoteField()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            
            TextField("Enter a quote from the media...", text: $viewModel.quote, axis: .vertical)
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
                            .fill(Theme.accent.opacity(0.5))
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
            
            TextEditor(text: $viewModel.noteText)
                .font(Theme.bodyFont(size: 17))
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isNoteFieldFocused)
                .frame(minHeight: 200)
                .padding(Theme.spacingMD)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMD))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMD)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .overlay(
                    Group {
                        if viewModel.noteText.isEmpty {
                            Text("What are you thinking about this?")
                                .font(Theme.bodyFont(size: 17))
                                .foregroundStyle(Theme.textTertiary)
                                .padding(Theme.spacingMD)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            HStack {
                Spacer()
                Text("\(viewModel.characterCount) characters")
                    .font(Theme.monoFont(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }
    
    // MARK: - Optional Fields Toggle
    
    private var optionalFieldsToggle: some View {
        HStack {
            if !viewModel.showQuoteField {
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
            }
            
            Spacer()
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
    
    return dependencies.makeAddNoteView(preselectedMedia: nil)
}
