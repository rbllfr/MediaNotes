import Foundation

/// Represents the state of a view's data loading lifecycle
enum ViewState<T>: Equatable where T: Equatable {
    case empty
    case loading
    case ready(T)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isReady: Bool {
        if case .ready = self { return true }
        return false
    }
    
    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
    
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var data: T? {
        if case .ready(let data) = self { return data }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}


