import ComposableArchitecture
import Foundation
import SwiftData
import Persistence
import Auth

@Reducer
public struct Diary {
    public init() { }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("client_uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        let calendar: Calendar
        var focusDate: Date
        var focusedEntries: [Entry]
        
        var isSigningOut = false
        var isLoading = false
        var hasLoaded = false
        var loadError: String?
        var sessionError: String?
        var loadGeneration = 0

        
        
        @Presents var destination: Destination.State?
        
        public init(
            focusDate: Date = .now,
            focusedEntries: [Entry] = [],
            calendar: Calendar = .autoupdatingCurrent
        ) {
            self.calendar = calendar
            self.focusDate = focusDate
            self.focusedEntries = focusedEntries
        }
    }
    
    public enum Action: ViewAction, Equatable, Sendable {
        case view(ViewActions)
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case signedOut
        }
        case `internal`(InternalActions)
        
        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didAppear
            case didTapRetry
            case dismissSessionError
            case didTapSearch
            
            case didTapEntryCard(Entry)
            case didTapCalendarDate(Date)
            case didTapMemoirButton
            
            case didTapNavigateToSetting
            
            case binding(_ action: BindingAction<State>)
        }
        
        @CasePathable
        public enum InternalActions: Sendable, Equatable {
            case didLoadEntries(generation: Int, entries: [Entry])
            case didFailLoading(generation: Int)
            case didSignOut
            case didFailSignOut
            
        }
        
    }
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case setting(Setting)
        case search(Search)
        case detail(Detail)
        case memoir(Memoir)
    }
    
    @Dependency(\.entryStore) private var entryStore
    @Dependency(\.sessionClient) private var session

    private enum CancelID { case load }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.didAppear), .view(.didTapRetry):
                return loadEntries(state: &state)
            case .view(.dismissSessionError):
                state.sessionError = nil
                return .none
            case let .view(.didTapCalendarDate(date)):
                state.focusDate = date
                return loadEntries(state: &state)
            case let .internal(.didLoadEntries(generation, entries)):
                guard generation == state.loadGeneration else { return .none }
                state.isLoading = false
                state.hasLoaded = true
                state.loadError = nil
                state.focusedEntries = entries.sorted { $0.createdAt > $1.createdAt }
                return .none
            case let .internal(.didFailLoading(generation)):
                guard generation == state.loadGeneration else { return .none }
                state.isLoading = false
                state.loadError = String(localized: "Your diary entries couldn’t be loaded. Please try again.")
                return .none
            case let .view(.didTapEntryCard(entry)):
                state.destination = .detail(Detail.State(entry: entry))
                return .none
            case .view(.didTapMemoirButton):
                state.destination = .memoir(Memoir.State())
                return .none
            case .view(.didTapNavigateToSetting):
                state.destination = .setting(Setting.State(diaryName: state.diaryName, isSigningOut: state.isSigningOut))
                return .none
            case .view(.didTapSearch):
                state.destination = .search(Search.State(ownerID: state.uid))
                return .none
            case let .destination(.presented(.search(.delegate(.didSelectEntry(entry))))):
                state.destination = .detail(Detail.State(entry: entry))
                return .none
            case .destination(.presented(.setting(.delegate(.signOutRequested)))):
                guard !state.isSigningOut else { return .none }
                state.isSigningOut = true
                state.sessionError = nil
                return .run { send in
                    do {
                        try await session.signOut()
                        await send(.internal(.didSignOut))
                    } catch {
                        await send(.internal(.didFailSignOut))
                    }
                }
            case .internal(.didSignOut):
                state.isSigningOut = false
                state.$uid.withLock { $0 = "" }
                state.$diaryName.withLock { $0 = "" }
                state.focusedEntries = []
                state.sessionError = nil
                state.loadGeneration += 1
                return .merge(.cancel(id: CancelID.load), .send(.delegate(.signedOut)))
            case .internal(.didFailSignOut):
                state.isSigningOut = false
                state.sessionError = String(localized: "You couldn’t be signed out. Open Settings to try again.")
                if case .setting = state.destination {
                    return .send(.destination(.presented(.setting(.signOutFailed))))
                }
                return .none
            case .destination(.presented(.memoir(.destination(.presented(.result(.didSaveEntry)))))):
                return loadEntries(state: &state)
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func loadEntries(state: inout State) -> Effect<Action> {
        state.loadGeneration += 1
        state.focusedEntries = []
        state.loadError = nil
        state.hasLoaded = false
        guard !state.uid.isEmpty,
              let interval = state.calendar.dateInterval(of: .day, for: state.focusDate) else {
            state.isLoading = false
            state.loadError = String(localized: "Sign in again to load your diary entries.")
            return .cancel(id: CancelID.load)
        }
        state.isLoading = true
        let generation = state.loadGeneration
        let ownerID = state.uid
        return .run { send in
            do {
                let records = try await entryStore.load(interval.start, interval.end, ownerID)
                try _Concurrency.Task.checkCancellation()
                let entries = records.map {
                    Entry(id: $0.id, title: $0.title, content: $0.content, createdAt: $0.createdAt)
                }
                await send(.internal(.didLoadEntries(generation: generation, entries: entries)))
            } catch is CancellationError {
                return
            } catch {
                await send(.internal(.didFailLoading(generation: generation)))
            }
        }
        .cancellable(id: CancelID.load, cancelInFlight: true)
    }
}
