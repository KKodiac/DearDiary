import Foundation

public protocol UserCommandRepository {
    func create(
        name: String,
        email: String,
        password: String?
    ) async throws
    
    func upsert(
        id: UUID,
        name: String,
        email: String,
        password: String?
    ) async throws
}

public protocol UserQueryRepository {
    func find(by id: UUID) async -> Predicate<UserModel>
    func find(by name: String) async -> Predicate<UserModel>
}

public protocol UserRepository: UserCommandRepository, UserQueryRepository { }
