//
//  LearningCardModel.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import Foundation

// Model now conforms to Codable and data is loaded from JSON
struct LearningCardModel: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    let learnCards: [LearnCard]
    
    var cardProgress: Int {
        learnCards.filter(\.self.isViewed).count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LearnCard: Hashable, Codable {
    let title: String
    let content: String
    var isViewed: Bool

    mutating func updateView(_ value: Bool) {
        isViewed = value
    }
}

struct LearningCardProgressModel {
    var learnCard: LearnCard
    let currentIndex: Int
    let totalCount: Int
    let title: String
}

struct LearningCardDataLoader {
    static func load(fromFile fileName: String = "learning_cards", withExtension ext: String = "json") -> [LearningCardModel] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            #if DEBUG
            print("[LearningCardDataLoader] Missing JSON resource: \(fileName).\(ext)")
            #endif
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode([LearningCardModel].self, from: data)
        } catch {
            #if DEBUG
            print("[LearningCardDataLoader] Failed to decode JSON: \(error)")
            #endif
            return []
        }
    }
}


// MARK: - Card Model
struct ExploreCard: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case imageName
    }
}

// MARK: - Learning Cards Container
struct ExploreLearningCardsData: Codable {
    let resumeLearning: [ExploreCard]
    let bookmarked: [ExploreCard]
    let topics: [ExploreCard]

    enum CodingKeys: String, CodingKey {
        case resumeLearning = "resumeLearning"
        case bookmarked = "Bookmarked"
        case topics = "Topics"
    }
}

// MARK: - Sample Data
extension ExploreLearningCardsData {
    static let sample = ExploreLearningCardsData(
        resumeLearning: [
            ExploreCard(title: "Frontend Frameworks", description: "Build Reliable Infrastructure", imageName: "resumeLearning1"),
            ExploreCard(title: "Cybersecurity", description: "Build Reliable Infrastructure", imageName: "resumeLearning2")
        ],
        bookmarked: [
            ExploreCard(title: "Mobile App Dev", description: "Build Reliable Infrastructure", imageName: "bookmarked1"),
            ExploreCard(title: "Data Engineering", description: "Build Reliable Infrastructure", imageName: "bookmarked2"),
            ExploreCard(title: "Agentic", description: "Build Reliable Infrastructure", imageName: "bookmarked3")
        ],
        topics: [
            ExploreCard(title: "Agentic AI", description: "Building Agentic AI framewors", imageName: "topics1"),
            ExploreCard(title: "Generative AI & LLMs", description: "Understand how LLMs generate new content", imageName: "topics2"),
            ExploreCard(title: "Containerization", description: "Using Docker, Kubernetes, and automation tools.", imageName: "topics3"),
            ExploreCard(title: "Cybersecurity", description: "Securing code and handling vulnerabilities.", imageName: "topics4"),
            ExploreCard(title: "Mobile App Development", description: "Building responsive, cross-platform mobile apps.", imageName: "topics5"),
            ExploreCard(title: "Data Engineering & Analytics", description: "Managing and visualizing big data.", imageName: "topics6")
        ]
    )
}
