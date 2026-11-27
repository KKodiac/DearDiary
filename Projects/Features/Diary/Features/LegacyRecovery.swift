import Auth
import ComposableArchitecture
import Foundation
import Persistence

@Reducer
public struct LegacyRecovery {
    @ObservableState
    public struct State: Equatable, Sendable {
        let ownerID: String
        var account: SessionClient.Account?
        var entries: [StoredEntry] = []
        var reviewedEntry: StoredEntry?
        var isLoading = false
        var hasLoaded = false
        var isRecovering = false
        var didRecoverEntry = false
        var error: String?
    }

    public enum Action: Equatable, Sendable {
        case load
        case loaded(SessionClient.Account, [StoredEntry])
        case review(StoredEntry)
        case cancelReview
        case confirmOwnership
        case recovered(UUID)
        case failed(String)
        case sessionChanged
        case entriesChanged
    }

    @Dependency(\.entryStore) private var entryStore
    @Dependency(\.sessionClient) private var session

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                guard !state.isLoading, !state.isRecovering else { return .none }
                state.isLoading = true
                state.hasLoaded = false
                state.account = nil
                state.entries = []
                state.reviewedEntry = nil
                state.error = nil
                let ownerID = state.ownerID
                return .run { send in
                    guard let account = try? await session.currentAccount(), account.id == ownerID else {
                        await send(.failed("Sign in again to review older entries."))
                        return
                    }
                    do {
                        let entries = try await entryStore.legacyEntries()
                        await send(.loaded(account, entries))
                    } catch {
                        await send(.failed("Older entries couldn’t be loaded. Please try again."))
                    }
                }
            case let .loaded(account, entries):
                state.isLoading = false
                state.hasLoaded = true
                state.account = account
                state.entries = entries
                return .none
            case let .review(entry):
                guard !state.isRecovering, state.entries.contains(entry) else { return .none }
                state.reviewedEntry = entry
                state.error = nil
                return .none
            case .cancelReview:
                guard !state.isRecovering else { return .none }
                state.reviewedEntry = nil
                state.error = nil
                return .none
            case .confirmOwnership:
                guard !state.isRecovering, let entry = state.reviewedEntry, let account = state.account else {
                    return .none
                }
                state.isRecovering = true
                state.error = nil
                return .run { send in
                    guard let currentAccount = try? await session.currentAccount(), currentAccount == account else {
                        await send(.sessionChanged)
                        return
                    }
                    do {
                        try await entryStore.recoverLegacyEntry(entry.id, account.id)
                        await send(.recovered(entry.id))
                    } catch EntryStorageError.ownershipMismatch {
                        await send(.failed("This entry is no longer available for recovery. Reload older entries to continue."))
                    } catch {
                        await send(.failed("This entry couldn’t be recovered. Please try again."))
                    }
                }
            case let .recovered(id):
                state.isRecovering = false
                state.didRecoverEntry = true
                state.entries.removeAll { $0.id == id }
                state.reviewedEntry = nil
                return .send(.entriesChanged)
            case let .failed(message):
                state.isLoading = false
                state.isRecovering = false
                state.error = message
                return .none
            case .sessionChanged:
                state.isRecovering = false
                state.hasLoaded = false
                state.account = nil
                state.entries = []
                state.reviewedEntry = nil
                state.error = "Your signed-in account changed. Close recovery and sign in again."
                return .none
            case .entriesChanged:
                return .none
            }
        }
    }
}
