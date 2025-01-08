import ComposableArchitecture
import SwiftUI
import Combine
import OSLog

@Reducer
public struct Setting {
    public init() { }
    @ObservableState
    public struct State: Equatable, Sendable {
        
    }
    
    public enum Action: Equatable, Sendable {
        
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
