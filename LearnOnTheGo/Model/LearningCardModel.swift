//
//  LearningCardModel.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import Foundation

struct LearningCardModel: Identifiable, Hashable {
    let id = UUID()
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
    
    static var defaultCard: LearningCardModel {
        
        let content = """
        Retrieval-Augmented Generation (RAG) combines two AI skills — retrieval (finding facts) and generation (creating answers).
        It fetches the latest info before writing, keeping responses fresh, accurate, and relevant.
        """
        let content2 = """
        Your Question → You ask something.
        Fact Hunt → RAG searches databases, articles, or documents.
        Smart Answer → AI weaves the facts into a tailored, natural-sounding reply.
        
        Think of it as asking a librarian who also happens to be a skilled writer!
        """
        let content3 = """
        Without retrieval, AI relies only on what it was trained on — which can be stale.
        With RAG, you get:
        Up-to-date info
        Reduced hallucinations (AI making stuff up)
        Higher accuracy for decision-making.
        It’s like GPS navigation that always checks live traffic before giving you directions.
        """
        
        let content4 = """
            RAG is perfect for:
                        -> Research & reports
                        -> Customer support
                        -> Legal & compliance queries
                        -> Medical info lookup
                        -> Basically, anywhere accuracy and context matter most.
            """
        
        let content5 = """
            RAG = AI with a fact-checker in its pocket.
            
            By fetching real-time info before answering, it delivers responses that are factual, current, and relevant — so you can trust what you read.
            """
        
        let cards = [
            LearnCard(title: "Meet RAG: AI's Smartest Upgrade", content: content, isViewed: false),
            LearnCard(title: "How RAG Works in 3 Steps", content: content2, isViewed: false),
            LearnCard(title: "Why RAG Beats Plain AI", content: content3, isViewed: false),
            LearnCard(title: "Where RAG Shines", content: content4, isViewed: false),
            LearnCard(title: "The Bottom Line", content: content5, isViewed: false)
            
        ]
        
        return LearningCardModel(title: "Mastering MCP Servers",
                          description: "Build Reliable Infrastructure",
                          imageName: "RecommendedImage1",
                          learnCards: cards)
    }
}

struct LearnCard: Hashable {
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
