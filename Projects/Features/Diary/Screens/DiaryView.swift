import ComposableArchitecture
import DesignSystem
import SwiftUICalendar
import SwiftUI

@ViewAction(for: Diary.self)
public struct DiaryView: View {
    @Bindable public var store: StoreOf<Diary>
    @StateObject private var controller = CalendarController()
    @ScaledMetric(relativeTo: .caption) private var calendarTextHeight = 16.0
    
    public init(store: StoreOf<Diary>) {
        self.store = store
    }
    
    public var body: some View {
        mainContent
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                floatingActionButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
            }
        .navigationDestination(
            item: $store.scope(state: \.destination?.search, action: \.destination.search)
        ) { store in
            SearchScreen(store: store)
        }
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.memoir,
                action: \.destination.memoir
            )
        ) { store in
            MemoirScreen(store: store)
                .navigationBarBackButtonHidden()
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                headerView
                if let error = store.sessionError {
                    sessionErrorBanner(error)
                }
                calendarView
                listView
            }
        }
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor.ignoresSafeArea())
    }

    private func sessionErrorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(message)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                send(.dismissSessionError)
            } label: {
                Image(systemName: "xmark")
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Dismiss sign-out error")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .foregroundStyle(.primary)
        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Dear Diary")
                .primaryTextStyle()
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                send(.didTapSearch)
            } label: {
                Image(systemName: "magnifyingglass")
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Search diary")
            settingsButton
        }
        .padding(20)
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.setting,
                action: \.destination.setting
            )
        ) { store in
            SettingView(store: store)
        }
    }
    
    // MARK: - Calendar
    private var calendarView: some View {
        VStack {
            calendarHeader
            calendarGrid
        }
        .onAppear { send(.didAppear) }
    }
    
    private var calendarHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            previousButton
            monthYearLabel
            nextButton
        }
    }
    
    private var previousButton: some View {
        calendarNavigationButton(direction: .previous)
    }
    
    private var nextButton: some View {
        calendarNavigationButton(direction: .next)
    }
    
    private func calendarNavigationButton(direction: NavigationDirection) -> some View {
        Button {
            let value = direction == .previous ? -1 : 1
            controller.scrollTo(controller.yearMonth.addMonth(value: value), isAnimate: true)
        } label: {
            Image(systemName: direction == .previous ? "chevron.backward" : "chevron.forward")
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(direction == .previous ? "Previous month" : "Next month")
    }
    
    private var monthYearLabel: some View {
        let month = controller.yearMonth
        let heading = "\(month.year).\(month.month)"
        let spokenMonth = Calendar.current.date(from: month.toDateComponents())?
            .formatted(.dateTime.month(.wide).year())
        return Text(heading)
            .font(.headline)
            .accessibilityLabel(spokenMonth ?? heading)
            .accessibilityAddTraits(.isHeader)
            .padding(.vertical)
    }
    
    private var calendarGrid: some View {
        CalendarView(
            controller,
            headerSize: .ratio,
            header: { weekHeader($0) },
            component: { dateCell($0) }
        )
        .frame(height: max(44, calendarTextHeight + 8) * 7)
        .padding(.horizontal, 4)
    }
    
    private func weekHeader(_ week: Week) -> some View {
        GeometryReader { proxy in
            Text("\(week.shortString.first?.uppercased() ?? "")")
                .font(.subheadline)
                .bold()
                .frame(width: proxy.size.width,
                       height: proxy.size.height,
                       alignment: .center)
                .accessibilityHidden(true)
        }
    }
    
    private func dateCell(_ date: YearMonthDay) -> some View {
        let isSelected = store.focusDate == date
        let dayColor = date.isFocusYearMonth == true ? Color.primary : DesignSystemAsset.ddPrimary.swiftUIColor
        return Button {
            send(.didTapCalendarDate(date))
        } label: {
            Text("\(date.day)")
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(4)
                .background {
                    if isSelected {
                        Circle().fill(DesignSystemAsset.ddAccentFill.swiftUIColor)
                    }
                }
                .foregroundStyle(isSelected ? Color.white : dayColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.date?.formatted(date: .complete, time: .omitted) ?? String(date.day))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // MARK: - List
    private var listView: some View {
        LazyVStack {
            dateHeader
            entriesList
        }
        .padding(.top)
        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.detail,
                action: \.destination.detail
            )
        ) { store in
            DiaryDetailView(store: store)
                .navigationBarBackButtonHidden()
        }
    }
    
    private var dateHeader: some View {
        Text(store.focusDate.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    @ViewBuilder
    private var entriesList: some View {
        if store.isLoading {
            ProgressView("Loading diary…")
                .padding()
        } else if let error = store.loadError {
            VStack(spacing: 12) {
                Text(error).font(.callout)
                Button {
                    send(.didTapRetry)
                } label: {
                    Text("Try Again")
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
            }
            .padding()
        } else if store.hasLoaded && store.focusedEntries.isEmpty {
            ContentUnavailableView(
                "No entries for this day",
                systemImage: "book.closed",
                description: Text("Start a conversation to write a diary entry.")
            )
        } else {
            ForEach(store.focusedEntries, id: \.self) { entry in
                entryCard(for: entry)
            }
        }
    }

    private func entryCard(for entry: Entry) -> some View {
        Button {
            send(.didTapEntryCard(entry))
        } label: {
            Card(title: entry.title, content: entry.content, timestamp: entry.createdAt)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Open diary entry")
    }
    
    // MARK: - Supporting Views
    private var floatingActionButton: some View {
        FloatingButton(image: DesignSystemAsset.imoji) {
            send(.didTapMemoirButton)
        }
        .accessibilityLabel("Open diary conversation")
        .padding()
    }
    
    private var settingsButton: some View {
        Button {
            send(.didTapNavigateToSetting)
        } label: {
            Image(systemName: "gear")
                .font(.title)
                .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
                .foregroundStyle(.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Settings")
    }
}

// MARK: - Supporting Types
private enum NavigationDirection {
    case previous, next
}
