import ComposableArchitecture
import Firebase
@preconcurrency import GoogleSignIn

extension DependencyValues {
    var google: GIDSignIn {
        get { self[GIDSignIn.self] }
        set { self[GIDSignIn.self] = newValue }
    }
}

extension GIDSignIn: @retroactive DependencyKey {
    public static var liveValue: GIDSignIn {
        .sharedInstance
    }

    public static var testValue: GIDSignIn {
        .sharedInstance
    }
}
