import ComposableArchitecture
import SwiftUI
import Combine
import OSLog

@Reducer
public struct Setting: Sendable {
    public init() { }
    @ObservableState
    public struct State: Sendable {
        
    }
    
    public enum Action: Sendable {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
            
        }
    }
}
