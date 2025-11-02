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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
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
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle")
                                .font(.subheadline)
                            Text("Developer")
                                .font(.subheadline).bold()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.95)))
                        .foregroundStyle(Color(red: 0.92, green: 0.27, blue: 0.27))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

                // Scrollable content below header
                ScrollView {
                    VStack(spacing: 20) {
                        // Recommended Learnings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommended Learnings")
                                .font(.title3).bold()
                                .foregroundStyle(.primary)
                            Text("Based on your Jira today: TASK-123 LLM Rag pipeline fix, TASK-342 MCP server crash. Recommended learnings below.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 16) {
                                LearningCard(title: "Mastering MCP Servers: Build Reliable Infrastructure", symbol: "bookmark")
                                LearningCard(title: "Unlocking RAG: AI-Powered Knowledge Retrieval", symbol: "bookmark")
                            }
                        }

                        // Tech Topics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tech Topics")
                                .font(.title3).bold()
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                TopicCard(title: "Cloud Computing", symbol: "cloud.fill")
                                TopicCard(title: "Agentic RAG", symbol: "atom")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .ignoresSafeArea(edges: .top) // let header hug the top
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct LearningCard: View {
    let title: String
    let symbol: String

    // You can adapt this to your real image asset name. For now, try to map from the symbol or use a placeholder.
    private var imageName: String {
        // If you have real assets, map them here. We'll use system image fallback.
        return "network" // placeholder asset name if available; the screen will also accept SF Symbols
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background card and content
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color(.systemGray5), Color(.systemGray3)], startPoint: .top, endPoint: .bottom))
                    .frame(height: 180)
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                    ProgressView(value: 0.35)
                        .tint(.white)
                        .progressViewStyle(.linear)
                        .blendMode(.plusLighter)
                }
                .padding(16)
            }

            // Top-right vertical action buttons
            VStack(spacing: 8) {
                Button {
                    // TODO: handle bookmark action
                } label: {
                    Image(systemName: "bookmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.25))
                        .clipShape(Circle())
                }

                NavigationLink {
                    PlayLearningCardScreen(title: title, image: Image(systemName: "atom"))
                } label: {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.25))
                        .clipShape(Circle())
                }
            }
            .padding(12)
        }
    }
}

private struct TopicCard: View {
    let title: String
    let symbol: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color(.systemGray6), Color(.systemGray4)], startPoint: .top, endPoint: .bottom))
                .frame(height: 150)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 6)

            HStack {
                Image(systemName: symbol)
                    .foregroundStyle(.white)
                    .font(.title2)
                Spacer()
                
            }
            .padding(12)

            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.white)
                .padding(12)
        }
    }
}

private struct ExploreView: View {
    @State private var searchText: String = ""

    struct ExploreLearning: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let progress: Double
    }

    private var allLearnings: [ExploreLearning] = [
        ExploreLearning(title: "Frontend Frameworks", progress: 0.35),
        ExploreLearning(title: "Cybersecurity", progress: 0.50),
        ExploreLearning(title: "Mobile App Dev", progress: 0.25),
        ExploreLearning(title: "Data Engineering", progress: 0.40),
        ExploreLearning(title: "Agentic", progress: 0.20)
    ]
    
    private var allTopics: [String] = [
        "Agentic AI",
        "Generative AI & LLMs",
        "Containerization",
        "Cybersecurity",
        "Mobile App Development",
        "Data Engineering & Analytics",
        "Cloud Native Development",
        "Frontend Frameworks"
    ]

    private var filteredLearnings: [ExploreLearning] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return allLearnings }
        return allLearnings.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    private var filteredTopics: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return allTopics }
        return allTopics.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky red header
                ZStack {
                    Color(red: 0.92, green: 0.27, blue: 0.27)
                        .frame(height: 64)
                    Text("Explore")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

                ScrollView {
                    VStack(spacing: 20) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search", text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 0.5))

                        // Resume Learning
                        SectionHeader(title: "Resume Learning", actionTitle: "See All")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(filteredLearnings) { item in
                                    ResumeCard(title: item.title, progress: item.progress)
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Bookmarked
                        SectionHeader(title: "Bookmarked", actionTitle: "See All")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(filteredLearnings) { item in
                                    BookmarkTile(title: item.title)
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Topics grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Topics")
                                .font(.title3).bold()
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredTopics, id: \.self) { topic in
                                    TopicLargeCard(title: topic)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct SectionHeader: View {
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

private struct ResumeCard: View {
    let title: String
    let progress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 220, height: 120)
                .overlay(
                    Text("")
                )

            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.primary)
            Text("3 of 8 cards completed")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                Spacer()
                Button {
                } label: {
                    Text("Continue")
                        .font(.caption).bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 1.0, green: 0.85, blue: 0.85)))
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 4)
    }
}

private struct BookmarkTile: View {
    let title: String
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 90, height: 90)
                .overlay(Image(systemName: "bookmark.fill").foregroundStyle(.red))
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

private struct TopicLargeCard: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray5))
                .frame(height: 150)
            Text(title)
                .font(.subheadline).bold()
            Text("Brief description of the topic goes here.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
            // Background — replace with your brand gradient or color
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Logo — replace "app.logo" with your asset name, or keep SF Symbol as placeholder
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                // Title — customize to match Figma
                Text("Insights")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                // Optional subtitle/tagline
                Text("Learn on the go")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
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

#Preview {
    ContentView()
}

