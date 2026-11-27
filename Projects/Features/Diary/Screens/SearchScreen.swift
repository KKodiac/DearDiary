import ComposableArchitecture
import DesignSystem
import SwiftUI

public struct SearchScreen: View {
    public let store: StoreOf<Search>

    public init(store: StoreOf<Search>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            searchField
                .padding()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
        .navigationTitle("Search Diary")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { store.send(.disappeared) }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(
                "Search titles and entries",
                text: Binding(
                    get: { store.query },
                    set: { store.send(.queryChanged($0)) }
                )
            )
            .submitLabel(.search)
            .onSubmit { store.send(.submit) }
            .accessibilityLabel("Search diary entries")
            if !store.query.isEmpty {
                Button {
                    store.send(.queryChanged(""))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, 4)
        .frame(minHeight: 52)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            ProgressView("Searching your diary…")
        } else if let error = store.errorMessage {
            ContentUnavailableView {
                Label("Search unavailable", systemImage: "exclamationmark.magnifyingglass")
            } description: {
                Text(error)
            } actions: {
                Button("Try Again") { store.send(.retry) }
                    .buttonStyle(.borderedProminent)
            }
        } else if !store.hasSearched {
            ContentUnavailableView(
                "Find a memory",
                systemImage: "magnifyingglass",
                description: Text("Search for words in your diary titles and entries.")
            )
        } else if store.entries.isEmpty {
            ContentUnavailableView(
                "No matching entries",
                systemImage: "book.closed",
                description: Text("Try another word or a shorter phrase.")
            )
        } else {
            List(store.entries) { entry in
                Button {
                    store.send(.didTapEntry(entry))
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(entry.content)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        Text(entry.createdAt, format: .dateTime.year().month().day())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityHint("Open diary entry")
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
