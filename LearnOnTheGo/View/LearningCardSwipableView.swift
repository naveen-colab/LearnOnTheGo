//
//  LearningCardSwipableView.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import SwiftUI

struct LearningCardSwipableView: View {
    var model: LearningCardModel
    @State private var currentIndex: Int = 0 {
        didSet {
            print("Tester: currentIndex is now \(currentIndex)")
        }
    }
    @State private var dragOffset: CGFloat = 0
    private let swipeThreshold: CGFloat = 120
    
    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            ZStack {
                
                if dragOffset < 0 {
                    // dragging up: show next card coming from bottom
                    if let next = cardModel(at: currentIndex + 1) {
                        LearnCardView(learningCardModel: next)
                            // Start just below and move up with a bit of parallax
//                            .offset(y: height + dragOffset * 0.7)
                            // Zoom the behind card in as you drag up. When dragOffset == 0 -> 0.92, when -height -> ~1.0
                            .scaleEffect(max(0.9, min(1.0, 0.92 + (-dragOffset / max(height, 1)) * 0.08)))
                            // Slight fade in as it approaches
                            .opacity(max(0.85, min(1.0, 0.85 + (-dragOffset / max(height, 1)) * 0.15)))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .animation(nil, value: dragOffset)
                            .allowsHitTesting(false)
                    }
                }
                
                
                // Current card on top following the finger
                if let current = cardModel(at: currentIndex) {
                    LearnCardView(learningCardModel: current)
                        .id(currentIndex)
                        .offset(y: dragOffset > 0 ? 0 : dragOffset)
                        // Slightly shrink current card as it moves away to sell the depth effect
                        .scaleEffect(
                            dragOffset == 0 ? 1.0 : max(0.8, 1.0 - abs(dragOffset) / max(height, 1) * 0.06)
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2), value: dragOffset)
                        .animation(nil, value: currentIndex)
                }
                
                
                // Background/adjacent card depending on drag direction
                if dragOffset > 0 {
                    // dragging down: show previous card coming from top
                    if let prev = cardModel(at: currentIndex - 1) {
                        LearnCardView(learningCardModel: prev)
                            .offset(y: -height + dragOffset * 1)
                            // Zoom the behind card in as you drag down
//                            .scaleEffect(max(0.9, min(1.0, 0.92 + (dragOffset / max(height, 1)) * 0.08)))
                            .opacity(max(0.85, min(1.0, 0.85 + (dragOffset / max(height, 1)) * 0.15)))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .animation(nil, value: dragOffset)
                            .allowsHitTesting(false)
                    }
                }

                
            }
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            // Force an opaque navigation bar (no translucency at scroll edge)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarColorScheme(.none, for: .navigationBar)
            // Place a solid background under the nav bar so content never shows through
//            .background(Color.white.ignoresSafeArea(edges: .top))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        // Only consider vertical dragging
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let translation = value.translation.height
                        if -translation > swipeThreshold, cardModel(at: currentIndex + 1) != nil {
                            // Swipe up -> animate current off, then advance
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                dragOffset = -height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                currentIndex += 1
                                dragOffset = 0
                            }
                        } else if translation > swipeThreshold, cardModel(at: currentIndex - 1) != nil {
                            // Swipe down -> animate current off, then go back
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                dragOffset = height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                currentIndex -= 1
                                dragOffset = 0
                            }
                        } else {
                            // Revert
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }
    
    private func cardModel(at index: Int) -> LearningCardProgressModel? {
        // Guard against out-of-bounds
        guard index >= 0, index < model.learnCards.count else { return nil }
        return LearningCardProgressModel(
            learnCard: model.learnCards[index],
            currentIndex: index + 1,
            totalCount: model.learnCards.count,
            title: model.title
        )
    }
}

#Preview {
    NavigationStack {
        let content = """
        Retrieval-Augmented Generation (RAG) combines two AI skills — retrieval (finding facts) and generation (creating answers).
        It fetches the latest info before writing, keeping responses fresh, accurate, and relevant.
        """
        let content2 = """
        Vector databases store embeddings for fast similarity search. They power RAG by finding relevant context.
        """
        let content3 = """
        Prompt engineering guides the model. Keep prompts concise, provide context, and specify output format.
        """
        let cards = [
            LearnCard(title: "Meet RAG: AI's Smartest Upgrade", content: content, isViewed: false),
            LearnCard(title: "Why vectors?", content: content2, isViewed: false),
            LearnCard(title: "Prompts that work", content: content3, isViewed: false)
        ]
        let lm = LearningCardModel(title: "RAG", description: "RAG", imageName: "", learnCards: cards)
        LearningCardSwipableView(model: lm)
    }
}
