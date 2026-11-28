import Auth
import ComposableArchitecture
import Foundation

@Reducer
public struct Setting {
    public init() {}

    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("client_uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        var draftName: String
        var isSigningOut = false
        var isSignOutConfirmationPresented = false
        var errorMessage: String?
        @Presents var legacyRecovery: LegacyRecovery.State?

        public init(diaryName: String = "", isSigningOut: Bool = false) {
            draftName = diaryName
            self.isSigningOut = isSigningOut
        }
    }

    public enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case openLegacyRecovery
        case legacyRecovery(PresentationAction<LegacyRecovery.Action>)
        case saveName
        case requestSignOut
        case cancelSignOut
        case confirmSignOut
        case signOutFailed
        case delegate(Delegate)

        @CasePathable
        public enum Delegate: Equatable, Sendable {
            case signOutRequested
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .openLegacyRecovery:
                guard !state.uid.isEmpty, !state.isSigningOut else { return .none }
                state.legacyRecovery = LegacyRecovery.State(ownerID: state.uid)
                return .none
            case .saveName:
                let name = state.draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else {
                    state.errorMessage = "Give your diary a name before saving."
                    return .none
                }
                state.$diaryName.withLock { $0 = name }
                state.draftName = name
                state.errorMessage = nil
                return .none
            case .requestSignOut:
                guard !state.isSigningOut, state.legacyRecovery == nil else { return .none }
                state.isSignOutConfirmationPresented = true
                return .none
            case .cancelSignOut:
                state.isSignOutConfirmationPresented = false
                return .none
            case .confirmSignOut:
                guard !state.isSigningOut, state.legacyRecovery == nil else { return .none }
                state.isSignOutConfirmationPresented = false
                state.isSigningOut = true
                state.errorMessage = nil
                return .send(.delegate(.signOutRequested))
            case .signOutFailed:
                state.isSigningOut = false
                state.errorMessage = "You couldn’t be signed out. Please try again."
                return .none
            case .binding, .delegate, .legacyRecovery:
                return .none
            }
        }
        .ifLet(\.$legacyRecovery, action: \.legacyRecovery) {
            LegacyRecovery()
        }
    }
}
