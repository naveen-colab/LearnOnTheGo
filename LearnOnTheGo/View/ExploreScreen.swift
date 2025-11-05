//
//  ExploreScreen.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import SwiftUI

struct ExploreView: View {
    @State private var searchText: String = ""
    
    private var allLearnings: [LearningCardModel] = [
        .defaultCard,
        .defaultCard
    ]
    
    private var allTopics: [LearningCardModel] = [
        .defaultCard,
        .defaultCard,
        .defaultCard
    ]

    private var filteredLearnings: [LearningCardModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return allLearnings }
        return allLearnings.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    private var filteredTopics: [LearningCardModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return allTopics }
        return allTopics.filter { $0.title.localizedCaseInsensitiveContains(query) }
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
                            HStack(alignment: .top,spacing: 14) {
                                ForEach(filteredLearnings) { item in
                                    let total = max(item.learnCards.count, 1)
                                    let progress = Double(item.cardProgress) / Double(total)
                                    NavigationLink(value: item) {
                                        ResumeCard(title: item.title,
                                                   progress: progress)
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
                                ForEach(filteredLearnings) { item in
                                    NavigationLink(value: item) {
                                        BookmarkTile(title: item.title)
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
                                      alignment: .listRowSeparatorLeading ,
                                      spacing: 16) {
                                ForEach(filteredTopics, id: \.self) { topic in
                                    NavigationLink(value: topic) {
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
            .ignoresSafeArea(edges: .top)
            .toolbar(.hidden, for: .navigationBar)
        }
        
    }
}


#Preview {
    ExploreView()
}

struct ResumeCard: View {
    let title: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("RecommendedImage1")
                .resizable()
                .cornerRadius(8)
                .frame(width: 220, height: 120)

            Text(title)
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
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 6)
    }
}

struct BookmarkTile: View {
    let title: String
//    let image: String
    var body: some View {
        VStack(spacing: 8) {
            Image("RecommendedImage1")
                .resizable()
                .frame(width: 90, height: 90)
                .cornerRadius(8)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.red)
                        .padding(6)
                }
            
            Text(title)
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
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .truncationMode(.tail)
        }
    }
}


import SwiftUI

struct ExploreView1: View {
    @State private var searchText: String = ""
    
    private var allLearnings: [LearningCardModel] = [
        .defaultCard
    ]
    
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
            .navigationTitle("Explore")
        }
    }
}

// No remaining ExploreLearning struct here

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
