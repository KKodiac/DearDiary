import ComposableArchitecture
@preconcurrency import SwiftUICalendar
import Foundation
import SwiftData
import ExternalDependencies

@Reducer
public struct Diary {
    public init() { }
    
    @ObservableState
    public struct State: Equatable, Sendable {
        @Shared(.appStorage("client_uid")) var uid = ""
        @Shared(.appStorage("diary_name")) var diaryName = ""
        var focusDate: YearMonthDay
        var isPresented: Bool
        var dialogues: [Dialogue]
        var focusedEntries: [Entry]
        
        var isAlertPresented: Bool = false
        
        var alertState: AlertState<Action.Alert>?
        
        @Presents var destination: Destination.State?
        
        public init(
            focusDate: YearMonthDay = YearMonthDay.current,
            isPresented: Bool = true,
            dialogues: [Dialogue] = [],
            focusedEntries: [Entry] = []
        ) {
            self.focusDate = focusDate
            self.isPresented = isPresented
            self.dialogues = dialogues
            self.focusedEntries = focusedEntries
        }
    }
    
    public enum Action: ViewAction, Equatable, Sendable {
        case view(ViewActions)
        case `internal`(InternalActions)
        case alert(Action.Alert)
        
        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        public enum ViewActions: BindableAction, Sendable, Equatable {
            case didAppear
            
            case didTapEntryCard(Entry)
            case didTapSettingButton
            case didTapCalendarDate(YearMonthDay)
            case didTapMemoirButton
            
            case didTapNavigateToBack
            case didTapNavigateToSetting
            
            case binding(_ action: BindingAction<State>)
        }
        
        @CasePathable
        public enum InternalActions: Sendable, Equatable {
            case didFetchEntry([Entry])
            
            case didFetchEntries([Entry])
            case didFetchEntriesFailed
            case didFetchEntriesEmpty
        }
        
        @CasePathable
        public enum Alert: Sendable, Equatable {
            case didAlertTapCancelButton
            case didAlertTapAcceptButton
        }
    }
    
    @Reducer(state: .equatable, .sendable, action: .equatable, .sendable)
    public enum Destination {
        case setting(Setting)
        case detail(Detail)
        case memoir(Memoir)
    }
    
    @Dependency(\.dismiss) private var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        CombineReducers {
            NestedAction(\.view) { state, action in
                switch action {
                case .didAppear:
                    _ = state.focusDate
                    return .run { send in
                        //                    guard let date = focusDate.date else {
                        //                        await send(.didFetchEntriesFailed)
                        //                        return
                        //                    }
                        
                        //                    let entries = try await diary.fetch(date)
                        //                    await send(.didFetchEntry(entries))
                    }
                case let .didTapCalendarDate(date):
                    let focusDate = (date != state.focusDate ? date : YearMonthDay.current)
                    state.focusDate = focusDate
                    state.isPresented.toggle()
                    return .run { send in
                        //                    guard let date = focusDate.date else {
                        //                        await send(.didFetchEntriesFailed)
                        //                        return
                        //                    }
                        
                        //                    let entries = try await diary.fetch(date)
                        //                    await send(.didFetchEntry(entries))
                    } catch: { _, send in
                        await send(.internal(.didFetchEntriesFailed))
                    }
                    
                case .didTapEntryCard(let entry):
                    state.destination = .detail(Detail.State(entry: entry))
                    return .none
                case .didTapMemoirButton:
                    state.destination = .memoir(Memoir.State())
                    return .none
                case .didTapNavigateToSetting:
                    state.isAlertPresented.toggle()
                    return .none
                case .didTapNavigateToBack:
                    return .run { _ in
                        await dismiss()
                    }
                case .didTapSettingButton:
                    return .none
                case .binding(_):
                    return .none
                }
            }
            
            NestedAction(\.internal) { state, action in
                switch action {
                case let .didFetchEntry(entries):
                    state.focusedEntries = entries
                        .sorted(by: { $0.createdAt > $1.createdAt })
                    guard entries.isEmpty == false else {
                        return .send(.internal(.didFetchEntriesEmpty))
                    }
                    return .none
                    
                    
                case .didFetchEntriesFailed:
                    print("Fetch failed, what did you do this time 😔")
                    return .none
                    
                case .didFetchEntriesEmpty:
                    print("Fetch empty, empty I'm fine with 🫠")
                    return .none
                    
                case .didFetchEntries(_):
                    return .none
                }
            }
            
            
            NestedAction(\.alert) { state, action in
                switch action {
                    
                case .didAlertTapAcceptButton:
                    state.uid  = ""
                    state.diaryName = ""
                    return .run { send in
                        await dismiss()
                    } catch: { error, send in
                        print("Sign out failed miserably: \(error)")
                    }
                case .didAlertTapCancelButton:
                    state.isAlertPresented = false
                    return .none
                }
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
