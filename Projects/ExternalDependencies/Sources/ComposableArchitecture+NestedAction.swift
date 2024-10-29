import ComposableArchitecture

/*
 For more on using custom reducers to manage actions in TCA, refer to this guide:
 https://medium.com/@oliverfoggin/leveraging-custom-reducers-to-manage-actions-in-your-tca-app-d4c71719a1f6
*/
@Reducer
public struct NestedAction<State, Action, ChildAction> {
    @usableFromInline
    let toChildAction: AnyCasePath<Action, ChildAction>
    
    @usableFromInline
    let toEffect: (inout State, ChildAction) -> Effect<Action>
    
    @inlinable
    public init(
        _ toChildAction: CaseKeyPath<Action, ChildAction>,
        toEffect: @escaping (inout State, ChildAction) -> Effect<Action>
    ) {
        self.toChildAction = AnyCasePath(toChildAction)
        self.toEffect = toEffect
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        guard let childAction = self.toChildAction.extract(from: action) else {
            return .none
        }
        
        return toEffect(&state, childAction)
    }
}

