import Foundation
import SwiftData

import ComposableArchitecture

@ModelActor
final actor EntryModelRepository: EntryRepository {
    // MARK: - Query Repository Implementation
    func find(by id: UUID) -> Predicate<EntryModel> {
        #Predicate<EntryModel> {
            $0.id == id
        }
    }

    func find(by title: String) -> Predicate<EntryModel> {
        #Predicate<EntryModel> {
            $0.title == title
        }
    }

    func find(by title: String, and createAt: Date) -> Predicate<EntryModel> {
        #Predicate<EntryModel> {
            $0.title == title && $0.createdAt == createAt
        }
    }

    // MARK: - Command Repository Implementation
    public func create(
        title: String,
        content: String,
        createdAt: Date = .now
    ) async throws {
        try modelContext.transaction {
            let entry = EntryModel(
                title: title,
                content: content,
                createdAt: createdAt
            )
            modelContext.insert(entry)
        }
    }
    
    public func upsert(
        id: UUID,
        title: String,
        content: String,
        createdAt: Date
    ) async throws {
        try modelContext.transaction {
            let entry = EntryModel(
                id: id,
                title: title,
                content: content,
                createdAt: createdAt
            )
            modelContext.insert(entry)
        }
    }
    
    // MARK: - Private Properties
    private let modelContext: ModelContext
    private let transformer: ValueTransformer
}
