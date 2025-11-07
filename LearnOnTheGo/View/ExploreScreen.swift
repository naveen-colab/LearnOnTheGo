//
//  ExploreScreen.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import SwiftUI
internal import Combine

struct ExploreView: View {
    @State private var searchText: String = ""
    @StateObject private var viewModel = LearningCardsViewModel()
    @EnvironmentObject private var roleStore: RoleStore


    private var filteredResumeLearning: [ExploreCard] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return viewModel.learningCardsData?.resumeLearning ?? [] }
        return (viewModel.learningCardsData?.resumeLearning ?? []).filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var filteredBookmarked: [ExploreCard] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return viewModel.learningCardsData?.bookmarked ?? [] }
        return (viewModel.learningCardsData?.bookmarked ?? []).filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var filteredTopics: [ExploreCard] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return viewModel.learningCardsData?.topics ?? [] }
        return (viewModel.learningCardsData?.topics ?? []).filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky red header
                ZStack(alignment: .bottom) {
                    Color(red: 0.92, green: 0.27, blue: 0.27)
                        .frame(height: 90)

                    Text("Explore")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
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
                        SectionHeader(title: "Resume Learning", actionTitle: "")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 14) {
                                ForEach(filteredResumeLearning) { item in
                                    NavigationLink(value: convertToLearningCardModel(item)) {
                                        ResumeCard(card: item, progress: 0.5)
                                    }
                                    .tint(.black)
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Bookmarked
                        SectionHeader(title: "Bookmarked", actionTitle: "")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 14) {
                                ForEach(filteredBookmarked) { item in
                                    NavigationLink(value: convertToLearningCardModel(item)) {
                                        BookmarkTile(card: item)
                                    }
                                    .tint(.black)
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Topics grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Topics")
                                .font(.title3).bold()
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                                      alignment: .listRowSeparatorLeading,
                                      spacing: 16) {
                                ForEach(filteredTopics) { topic in
                                    NavigationLink(value: convertToLearningCardModel(topic)) {
                                        TopicLargeCard(title: topic.title,
                                                       image: topic.imageName,
                                                       description: topic.description)
                                        .tint(.black)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .navigationDestination(for: LearningCardModel.self) { model in
                    LearningCardSwipableView(model: model)
                }
            }
            .onAppear {
                viewModel.loadData(role: roleStore.current)
            }
            .ignoresSafeArea(edges: .top)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func convertToLearningCardModel(_ card: ExploreCard) -> LearningCardModel {
        // If this ExploreCard corresponds to the GENAI & ML topic, build learn cards from the provided content
        let lowerTitle = card.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let cardsToUse: [LearnCard]
        if lowerTitle.contains("genai") || lowerTitle.contains("ml") || lowerTitle.contains("machine learning") || lowerTitle.contains("generative ai") {
            cardsToUse = ExploreLearningCardsData.genAIAndMLCards
        } else {
            // Fallback to the card's existing learnCards, ensuring isViewed is present/false by default
            cardsToUse = card.learnCards.isEmpty ? [] : card.learnCards.map { existing in
                LearnCard(title: existing.title, content: existing.content, isViewed: false)
            }
        }

        return LearningCardModel(
            id: UUID(),
            title: card.title,
            description: card.description,
            imageName: card.imageName,
            learnCards: cardsToUse
        )
    }
}

// MARK: - View Model for Managing Data
class LearningCardsViewModel: ObservableObject {
    @Published var learningCardsData: ExploreLearningCardsData?

    func loadData(role: Role) {
        // Load from JSON file or API
        if let jsonPath = Bundle.main.path(forResource: "learning_cards", ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) {
            loadFromJSON(jsonData, role: role)
        }
    }

    func loadFromJSON(_ jsonData: Data, role: Role) {
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
                var resumeLearning: [ExploreCard] = []
                var bookmarked: [ExploreCard] = []
                var topics: [ExploreCard] = []

                for item in jsonArray {
                    if let resumeArray = item["Resume Learning"] as? [[String: String]] {
                        resumeLearning = resumeArray.map { ExploreCard(title: $0["title"] ?? "", description: $0["description"] ?? "", imageName: $0["imageName"] ?? "") }
                    }
                    if let bookmarkedArray = item["Bookmarked"] as? [[String: String]] {
                        bookmarked = bookmarkedArray.map { ExploreCard(title: $0["title"] ?? "", description: $0["description"] ?? "", imageName: $0["imageName"] ?? "") }
                    }
                    if let topicsArray = item["Topics"] as? [[String: String]] {
                        topics = topicsArray.map { ExploreCard(title: $0["title"] ?? "", description: $0["description"] ?? "", imageName: $0["imageName"] ?? "") }
                    }
                }

//                self.learningCardsData = ExploreLearningCardsData(resumeLearning: resumeLearning, bookmarked: bookmarked, topics: topics)
                self.learningCardsData = role == .developer ? ExploreLearningCardsData.sample : ExploreLearningCardsData.operationsDataSample
            }
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }
}

struct BookmarkTile: View {
    let card: ExploreCard
//    let image: String
    var body: some View {
        VStack(spacing: 8) {
            Image(card.imageName)
                .resizable()
                .frame(width: 90, height: 90)
                .cornerRadius(8)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.red)
                        .padding(6)
                }
            
            Text(card.title)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .frame(width: 110)
    }
}

struct TopicLargeCard: View {
    let title: String
    let image: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(image)
                .resizable()
                .cornerRadius(8)
                .frame(height: 150)
            Text(title)
                .font(.subheadline).bold()
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
        }
    }
}

struct ResumeCard: View {
    let card: ExploreCard
    let progress: Double

    var body: some View {
        VStack {
            Image(card.imageName)
                .resizable()
                .cornerRadius(8)
                .frame(width: 220, height: 120)
                .padding()
            VStack(alignment: .leading, spacing: 8) {
                Text(card.title)
                    .font(.subheadline).bold()
                    .foregroundStyle(.primary)
                Text("3 of 8 cards completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(Color.red)
                }
                Button {
                } label: {
                    Text("Continue")
                        .font(.caption).bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .tint(Color.red)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 1.0, green: 0.85, blue: 0.85)))
                }
            }
            .padding(12)
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 6)
    }
}

/*
import SwiftUI

struct ExploreView1: View {
    @State private var searchText: String = ""
    
    @State private var allLearnings: [LearningCardModel] = []
    
    private var filteredLearnings: [LearningCardModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return allLearnings }
        return allLearnings.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Resume Learning")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(filteredLearnings) { item in
                        let total = max(item.learnCards.count, 1)
                        let progress = Double(item.cardProgress) / Double(total)
                        ResumeCard(title: item.title, progress: progress)
                    }
                    
                    Text("Bookmarked")
                        .font(.headline)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                    
                    ForEach(filteredLearnings) { item in
                        BookmarkTile(title: item.title)
                    }
                }
                .padding()
            }
            .onAppear {
                self.allLearnings = LearningCardDataLoader.load()
            }
            .navigationTitle("Explore")
        }
    }
}
*/
// No remaining ExploreLearning struct here

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
            .environmentObject(RoleStore())
    }
}

