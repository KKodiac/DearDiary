import ComposableArchitecture
import SwiftUI
import Auth
import OSLog

@main
struct DearDiaryApp: App {
    init() {
        @Dependency(\.authClient) var authClient
        do {
            try authClient.configure()
        } catch {
            // Account presents a recoverable error when service configuration is absent.
            Logger(subsystem: "com.bibumtiger.deardiary", category: "Startup")
                .error("Authentication could not be initialized. Check the local service configuration.")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
