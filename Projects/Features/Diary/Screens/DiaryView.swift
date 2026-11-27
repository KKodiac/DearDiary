import ComposableArchitecture
import DesignSystem
import SwiftUICalendar
import SwiftUI

@ViewAction(for: Diary.self)
public struct DiaryView: View {
    @Bindable public var store: StoreOf<Diary>
    @StateObject private var controller = CalendarController()
    @Environment(\.colorScheme) private var colorScheme
    
    public init(store: StoreOf<Diary>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            mainContent
            floatingActionButton
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
        GeometryReader { proxy in
            VStack(spacing: 20) {
                headerView
                if let error = store.sessionError {
                    sessionErrorBanner(error)
                }
                calendarView
                listView
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
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
            }
            .accessibilityLabel("Dismiss sign-out error")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .foregroundStyle(.red)
        .background(.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Dear Diary").primaryTextStyle()
            Spacer()
            Button {
                send(.didTapSearch)
            } label: {
                Image(systemName: "magnifyingglass")
                    .frame(minWidth: 44, minHeight: 44)
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
            (direction == .previous ? DesignSystemAsset.arrowleft : DesignSystemAsset.arrowright)
                .swiftUIImage
        }
        .padding(25)
    }
    
    private var monthYearLabel: some View {
        Text("\(String(controller.yearMonth.year)).\(controller.yearMonth.month)")
            .font(.system(size: 20))
            .bold()
            .padding(.vertical)
    }
    
    private var calendarGrid: some View {
        CalendarView(
            controller,
            header: { weekHeader($0) },
            component: { dateCell($0) }
        )
        .padding([.horizontal, .bottom], 30)
    }
    
    private func weekHeader(_ week: Week) -> some View {
        GeometryReader { proxy in
            Text("\(week.shortString.first?.uppercased() ?? "")")
                .font(.subheadline)
                .bold()
                .frame(width: proxy.size.width,
                       height: proxy.size.height,
                       alignment: .center)
        }
    }
    
    @ViewBuilder
    private func dateCell(_ date: YearMonthDay) -> some View {
        GeometryReader { proxy in
            Text("\(date.day)")
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
                .font(.caption)
                .fontWeight(store.focusDate == date ? .bold : .light)
                .background(
                    DesignSystemAsset.ddAccent.swiftUIColor
                        .clipShape(Circle())
                        .opacity(store.focusDate == date ? 1 : 0)
                )
                .foregroundStyle(
                    store.focusDate == date 
                    ? Color.white 
                    : colorScheme == .dark ? .primary : Color.black
                )
                .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                .onTapGesture {
                    send(.didTapCalendarDate(date))
                }
        }
    }
    
    // MARK: - List
    private var listView: some View {
        VStack {
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
        Divider()
            .overlay {
                HStack {
                    Text("\(store.focusDate.date?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                        .foregroundStyle(Color.gray)
                        .padding(.trailing)
                        .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
                    Spacer()
                }
            }
            .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
            .padding()
    }
    
    @ViewBuilder
    private var entriesList: some View {
        if store.isLoading {
            ProgressView("Loading diary…")
                .padding()
        } else if let error = store.loadError {
            VStack(spacing: 12) {
                Text(error).font(.callout)
                Button("Try Again") { send(.didTapRetry) }
            }
            .padding()
        } else if store.hasLoaded && store.focusedEntries.isEmpty {
            ContentUnavailableView(
                "No entries for this day",
                systemImage: "book.closed",
                description: Text("Start a conversation to write a diary entry.")
            )
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(store.focusedEntries, id: \.self) { entry in
                        entryCard(for: entry)
                    }
                }
            }
        }
    }

    private func entryCard(for entry: Entry) -> some View {
        Button {
            send(.didTapEntryCard(entry))
        } label: {
            Card(title: entry.title, content: entry.content, timestamp: entry.createdAt)
        }
        .tint(.black)
    }
    
    // MARK: - Supporting Views
    private var floatingActionButton: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                FloatingButton(image: DesignSystemAsset.imoji) {
                    send(.didTapMemoirButton)
                }
            }
        }
        .padding()
    }
    
    private var settingsButton: some View {
        Button {
            send(.didTapNavigateToSetting)
        } label: {
            Image(systemName: "gear")
                .font(.title)
                .background(DesignSystemAsset.ddPrimaryBackground.swiftUIColor)
                .foregroundStyle(DesignSystemAsset.ddSecondary.swiftUIColor)
                .frame(minWidth: 44, minHeight: 44)
        }
        .accessibilityLabel("Settings")
    }
}

// MARK: - Supporting Types
private enum NavigationDirection {
    case previous, next
}
