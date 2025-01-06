import Testing
import SnapshotTesting
import ComposableArchitecture
@testable import Account

struct AccountTests {
    @MainActor
    @Test func account() async throws {
        let sut = TestStoreOf<Account>(initialState: Account.State()) {
            Account()
        } withDependencies: { dependencyValues in
            dependencyValues.authClient = .testValue
        }
        
        await sut.send(.view(.didAppear))
    }
}
