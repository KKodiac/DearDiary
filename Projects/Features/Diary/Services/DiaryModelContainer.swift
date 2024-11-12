import Foundation
import SwiftData

import ComposableArchitecture

extension DependencyValues {
    var diaryModelContainer: DiaryModelContainer {
        DiaryModelContainer()
    }
}

@ModelActor
final actor DiaryModelActor {
    func createDiaryEntry(title: String, content: String, createdAt: Date = .now) async {
        let entry = Entry(
            title: title,
            content: content,
            createdAt: createdAt
        )
    }
}

struct DiaryModelContainer {
    var container: ModelContainer?
    
    init(container: ModelContainer? = nil) {
        self.container = container
    }
}
