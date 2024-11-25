import Foundation
import SwiftData
import ComposableArchitecture

@ModelActor
final actor UserModelRepository: UserRepository {
    // MARK: - Query Repository Implementation
    func find(by id: UUID) async -> Predicate<UserModel> {
        #Predicate<UserModel> {
            $0.id == id
        }
    }
    
    func find(by name: String) async -> Predicate<UserModel> {
        #Predicate<UserModel> {
            $0.name == name
        }
    }
    
    // MARK: - Command Repository Implementation
    func create(
        name: String,
        email: String,
        password: String?
    ) async throws {
        try modelContext.transaction {
            let user = UserModel(
                name: name,
                email: email,
                password: password
            )
            modelContext.insert(user)
        }
    }

    func upsert(
        id: UUID,
        name: String,
        email: String,
        password: String?
    ) async throws {
        try modelContext.transaction {
            let user = UserModel(
                id: id,
                name: name,
                email: email,
                password: password
            )
            modelContext.insert(user)
        }
    }
}
