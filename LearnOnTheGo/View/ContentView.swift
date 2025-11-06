//
//  ContentView.swift
//  LearnOnTheGo
//
//  Created by AveMaria on 11/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            DashboardTabView()
                .opacity(showSplash ? 0 : 1)
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Simulate a short loading period; adjust to match your Figma timing.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

private struct DashboardTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)

            PodcastsView()
                .tabItem {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Podcasts")
                }
                .tag(2)

            VideosView()
                .tabItem {
                    Image(systemName: "play.rectangle")
                    Text("Videos")
                }
                .tag(3)
        }
        .tint(Color(red: 0.92, green: 0.27, blue: 0.27))
    }
}

private struct HomeView: View {
    enum Role: String, CaseIterable, Identifiable {
        case developer = "Developer"
        case operations = "Operations"
        var id: String { rawValue }
    }

    struct HomeContent: Identifiable {
        struct Topic: Identifiable { let id = UUID(); let title: String; let symbol: String; let image: String }
        let id = UUID()
        let headerSubtitle: String
        let recommended: [LearningCardModel]
        let topics: [Topic]
    }

    // Mapping from loader DTOs to UI models
    private func mapContent(from dto: RoleContentDTO) -> HomeContent {
        // Use explicit defaults with concrete element types so the compiler can infer correctly
        let cardsDTO: [LearningCardDTO] = dto.recommended ?? [LearningCardDTO]()
        let cards: [LearningCardModel] = cardsDTO.map { item in
            let learnCardTitles: [LearnCard] = item.learnCards ?? [LearnCard]()
//            let learnCards: [LearnCard] = learnCardTitles.map { LearnCard(title: $0, content: "", isViewed: false) }
            return LearningCardModel(
                id: UUID(),
                title: item.title ?? "",
                description: item.description ?? "",
                imageName: item.imageName ?? "",
                learnCards: learnCardTitles
            )
        }

        let topicsDTO: [TopicDTO] = dto.topics ?? [TopicDTO]()
        let topics: [HomeContent.Topic] = topicsDTO.map { t in
            HomeContent.Topic(title: t.title ?? "", symbol: t.symbol ?? "", image: t.image ?? "")
        }

        return HomeContent(
            headerSubtitle: dto.headerSubtitle ?? "",
            recommended: cards,
            topics: topics
        )
    }

    private func content(for role: Role) -> HomeContent? {
        guard let dto = loadedRoles.first(where: { ($0.role ?? "").caseInsensitiveCompare(role.rawValue) == .orderedSame }) else { return nil }
        return mapContent(from: dto)
    }

    @State private var currentRole: Role = .developer
    @State private var showRolePicker: Bool = false
    @State private var refreshToken: UUID = UUID()

    @State private var loadedRoles: [RoleContentDTO] = []
    @State private var loadError: String? = nil

    private func select(role: Role) {
        let roleChanged = currentRole != role
        currentRole = role
        showRolePicker = false
        if roleChanged {
            // Trigger a content refresh when role changes
            refreshToken = UUID()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky Header
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(red: 0.92, green: 0.27, blue: 0.27))
                        .frame(height: 96)
                    HStack(alignment: .center) {
                        Text("Hi, Rahul")
                            .font(.title2).bold()
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            showRolePicker = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.crop.circle")
                                    .foregroundStyle(Color(red: 0.92, green: 0.27, blue: 0.27))
                                    .background(
                                        Circle().fill(Color.white)
                                    )

                                Text(currentRole.rawValue)
                                    .font(.subheadline).bold()
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.55))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

                // Scrollable content below header
                ScrollView {
                    VStack(spacing: 20) {
                        if let data = content(for: currentRole) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recommended Learnings")
                                    .font(.title3).bold()
                                    .foregroundStyle(.primary)
                                Text(data.headerSubtitle)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)

                                VStack(spacing: 16) {
                                    ForEach(Array(data.recommended.enumerated()), id: \.offset) { _, card in
                                        NavigationLink(value: card) {
                                            LearningCard(model: card)
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Topics")
                                    .font(.title3).bold()
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(data.topics) { topic in
                                        TopicCard(title: topic.title, symbol: topic.symbol, image: topic.image)
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                if let loadError { Text("Failed to load content: \(loadError)").font(.footnote).foregroundStyle(.secondary) }
                                ProgressView("Loading content…")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .navigationDestination(for: LearningCardModel.self) { model in
                        LearningCardSwipableView(model: model)
                    }
                }
                .id(refreshToken)
            }
            .sheet(isPresented: $showRolePicker) {
                RolePickerSheet(current: currentRole) { role in
                    select(role: role)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .ignoresSafeArea(edges: .top) // let header hug the top
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            do {
                let payload = try RoleContentLoader.shared.loadRoles()
                loadedRoles = payload.roles ?? []
            } catch {
                loadError = String(describing: error)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let actionTitle: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Button(action: {}) {
                Text(actionTitle)
                    .font(.subheadline).bold()
            }
        }
    }
}





private struct PodcastsView: View {
    var body: some View {
        PodcastsScreen()
    }
}

private struct VideosView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Videos coming soon")
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct SplashView: View {
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Image("SplashScreen")
                .resizable()
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Logo — replace "app.logo" with your asset name, or keep SF Symbol as placeholder


                HStack {
                    Image("bookImage")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .scaledToFit()

                    VStack(alignment: .leading) {
                        // Optional subtitle/tagline
                        Text("Learn")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.redTint)


                        Text("On The Go")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.redTint)

                    }
                }
            }
            .multilineTextAlignment(.center)
            .scaleEffect(scale)
            .opacity(opacity)
            .padding(32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}

private struct RolePickerSheet: View {
    let current: HomeView.Role
    let onSelect: (HomeView.Role) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Role")
                .font(.headline)
                .padding(.top)

            ForEach(HomeView.Role.allCases) { role in
                Button {
                    onSelect(role)
                } label: {
                    HStack {
                        Text(role.rawValue)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        if role == current {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 8)
        }
        .padding()
        .presentationBackground(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
}
#Preview {
    HomeView()
}

