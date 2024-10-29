import ComposableArchitecture
import Foundation
import SwiftData

extension DependencyValues {
    var diaryModelContainer: DiaryModelContainer {
        DiaryModelContainer()
    }
}

struct DiaryModelContainer {
    var container: ModelContainer?
    
    init(container: ModelContainer? = nil) {
        self.container = container
    }
}

@ModelActor
final actor DiaryModel {
    
}
