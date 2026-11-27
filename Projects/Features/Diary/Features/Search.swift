import ComposableArchitecture
import Foundation
import Persistence

@Reducer
public struct Search {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        public let ownerID: String
        public var query = ""
        public var entries: [Entry] = []
        public var isLoading = false
        public var hasSearched = false
        public var errorMessage: String?
        var generation = 0

        public init(ownerID: String) {
            self.ownerID = ownerID
        }
    }

    public enum Action: Equatable, Sendable {
        case queryChanged(String)
        case submit
        case retry
        case disappeared
        case didTapEntry(Entry)
        case resultsReceived(generation: Int, entries: [Entry])
        case searchFailed(generation: Int)
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case didSelectEntry(Entry)
        }
    }

    @Dependency(\.entryStore) private var entryStore
    @Dependency(\.continuousClock) private var clock
    private enum CancelID { case search }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .queryChanged(query):
                state.query = query
                return search(state: &state, debounce: true)
            case .submit, .retry:
                return search(state: &state, debounce: false)
            case .disappeared:
                state.generation += 1
                state.isLoading = false
                return .cancel(id: CancelID.search)
            case let .resultsReceived(generation, entries):
                guard generation == state.generation else { return .none }
                state.entries = entries.sorted { $0.createdAt > $1.createdAt }
                state.isLoading = false
                state.hasSearched = true
                state.errorMessage = nil
                return .none
            case let .searchFailed(generation):
                guard generation == state.generation else { return .none }
                state.isLoading = false
                state.errorMessage = String(localized: "Your diary couldn’t be searched. Please try again.")
                return .none
            case let .didTapEntry(entry):
                guard state.entries.contains(where: { $0.id == entry.id }) else { return .none }
                return .send(.delegate(.didSelectEntry(entry)))
            case .delegate:
                return .none
            }
        }
    }

    private func search(state: inout State, debounce: Bool) -> Effect<Action> {
        state.generation += 1
        state.entries = []
        state.errorMessage = nil
        state.hasSearched = false
        state.isLoading = false
        let query = state.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return .cancel(id: CancelID.search) }
        guard !state.ownerID.isEmpty else {
            state.errorMessage = String(localized: "Sign in again to search your diary.")
            return .cancel(id: CancelID.search)
        }

        state.isLoading = true
        let generation = state.generation
        let ownerID = state.ownerID
        return .run { send in
            do {
                if debounce { try await clock.sleep(for: .milliseconds(300)) }
                let records = try await entryStore.search(query, ownerID)
                try _Concurrency.Task.checkCancellation()
                let entries = records.map {
                    Entry(id: $0.id, title: $0.title, content: $0.content, createdAt: $0.createdAt)
                }
                await send(.resultsReceived(generation: generation, entries: entries))
            } catch is CancellationError {
                return
            } catch {
                await send(.searchFailed(generation: generation))
            }
        }
        .cancellable(id: CancelID.search, cancelInFlight: true)
    }
}
