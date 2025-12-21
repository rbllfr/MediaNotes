import Foundation

/// Represents the state of a form's lifecycle
enum FormState: Equatable {
    case idle
    case saving
    case saved
    case error(String)
    
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
    
    var isSaving: Bool {
        if case .saving = self { return true }
        return false
    }
    
    var isSaved: Bool {
        if case .saved = self { return true }
        return false
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

