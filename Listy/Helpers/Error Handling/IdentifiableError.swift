// IdentifiableError.swift
import Foundation

struct IdentifiableError: Identifiable, LocalizedError {
    let id = UUID()
    let underlyingError: Error
    
    var errorDescription: String? {
        underlyingError.localizedDescription
    }
    
    init(_ error: Error) {
        self.underlyingError = error
    }
}
