import Foundation
import SwiftData

import Core

public struct Entry: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var content: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
    
    private func parse() -> Entry? {
        let pattern = #"Title:\s*(.*?)\n\n(.*)"#
        let range = NSRange(location: 0, length: content.utf16.count)
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: content, range: range),
              let titleRange = Range(match.range(at: 1), in: content) else {
            return nil
        }
        
        
        let title = String(content[titleRange])
        let content = String(content.replacingOccurrences(of: title, with: "")
            .replacingOccurrences(of: "Title:", with: ""))
        
        return .init(title: title, content: content)
    }
}

extension Entry: ValueObject {
    
}

extension Entry {
    public static let mock: [Entry] = [
        .init(
            title: "How my day went",
            content: """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce luctus imperdiet eros non facilisis. Suspendisse lacinia magna nulla, eget consectetur massa tempor sit amet. Morbi nec orci sed metus ornare maximus eget vel nulla. Quisque varius quam ac leo viverra, id placerat magna lobortis. Donec vulputate cursus imperdiet.Aenean sed lectus fringilla, consequat turpis nec, rutrum purus. Aenean dui mauris, ultrices eu consequat dignissim, elementum id nunc. Nullam efficitur suscipit augue, vitae commodo metus. Curabitur lacinia felis tortor. Nullam ac magna fringilla, aliquam leo facilisis, semper purus. Pellentesque luctus est id arcu tristique tristique.
                """
        ),
        .init(
            title: "I love my dog",
            content: """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce luctus imperdiet eros non facilisis.
                Suspendisse lacinia magna nulla, eget consectetur massa tempor sit amet. Morbi nec orci sed metus ornare maximus eget vel nulla. Quisque varius quam ac leo viverra, id placerat magna lobortis. Donec vulputate cursus imperdiet.
                Aenean sed lectus fringilla, consequat turpis nec, rutrum purus. Aenean dui mauris, ultrices eu consequat dignissim, elementum id nunc. Nullam efficitur suscipit augue, vitae commodo metus. Curabitur lacinia felis tortor.
                Nullam ac magna fringilla, aliquam leo facilisis, semper purus. Pellentesque luctus est id arcu tristique tristique.
                """
        ),
        .init(
            title: "Going on a roadtrip",
            content: """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce luctus imperdiet eros non facilisis.
                Suspendisse lacinia magna nulla, eget consectetur massa tempor sit amet. Morbi nec orci sed metus ornare maximus eget vel nulla. Quisque varius quam ac leo viverra, id placerat magna lobortis. Donec vulputate cursus imperdiet.
                Aenean sed lectus fringilla, consequat turpis nec, rutrum purus. Aenean dui mauris, ultrices eu consequat dignissim, elementum id nunc. Nullam efficitur suscipit augue, vitae commodo metus. Curabitur lacinia felis tortor.
                Nullam ac magna fringilla, aliquam leo facilisis, semper purus. Pellentesque luctus est id arcu tristique tristique.
                """
        )
    ]
}
