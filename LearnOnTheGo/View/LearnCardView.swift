//
//  LearnCardView.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import SwiftUI

let fontStyle = "Open sans"

struct fontModifer: ViewModifier {
    let style: String
    let size: Float
    func body(content: Content) -> some View {
        content
            .font(.custom(style, size: CGFloat(size)))
    }
}

extension View {
    func customFont(_ style: String = "Open Sans", size: Float) -> some View {
        self.modifier(fontModifer(style: style, size: size))
    }
}

// MARK: - Model contract the view expects
// This view expects an observable model named `LearningCardModel` to be provided
// either via initializer or as an EnvironmentObject. The model contract used here:
//
// final class LearningCardModel: ObservableObject {
//     @Published var title: String
//     @Published var subtitle: String? // optional small caption under the red bar
//     @Published var bodyText: AttributedString // rich text for the card body
//     @Published var currentIndex: Int
//     @Published var totalCount: Int
// }
//
// If your model differs, adapt the bindings in the view accordingly.


struct LearnCardView: View {
    // Prefer environment object so the caller can supply a single source of truth
    @State var learningCardModel: LearningCardProgressModel

    // Styling
    private let headerRed = Color.red
    private let cardCorner: CGFloat = 16

    var body: some View {
        VStack(spacing: 12) {
            // Top red bar (navigation bar background handled via toolbarBackground too)
            // Slim progress-like accent below the nav bar
            HStack {
                progressBar
                    .frame(maxWidth: .infinity)
                
                // Page indicator on the right (e.g., 1/5)
                Text("\(learningCardModel.currentIndex)/\(max(learningCardModel.totalCount, 1))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
            }
            .padding()

            // Card content
            card
                .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .onAppear {
            learningCardModel.learnCard.updateView(true)
        }
        .background(Color.white)
    }

    // MARK: - Components
    private var progressBar: some View {
        let progress = Double(learningCardModel.currentIndex) / Double(max(learningCardModel.totalCount, 1))
        return ZStack(alignment: .leading) {
            Capsule().fill(Color(.systemGray5)).frame(height: 6)
            GeometryReader { geo in
                Capsule()
                    .fill(Color.yellow)
                    .frame(width: max(0, geo.size.width * progress), height: 6)
            }
        }
        .frame(height: 6)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(learningCardModel.learnCard.title)
                .customFont(size: 48)
                .foregroundStyle(.red)
                .padding(.bottom, 16)

            // Big headline in red (first line of body can be styled red if desired)
            // Expecting `bodyText` to contain styling for emphasis where needed
            Text(learningCardModel.learnCard.content)
                .customFont(size: 24)
                .foregroundStyle(.primary)
                .lineSpacing(4)
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview
#Preview {
    let content = """
        Retrieval-Augmented Generation(RAG) combines two AI skills — retrieval (finding facts) and generation (creating answers).
        
        It fetches the latest info before writing, keeping responses fresh, accurate, and relevant.
        """
    let card = LearnCard(title: "Meet RAG: AI's Smartest Upgrade", content: content, isViewed: false)
    let vm = LearningCardProgressModel(learnCard: card, currentIndex: 1, totalCount: 5,title: "RAG")
    
    
    LearnCardView(learningCardModel: vm)
}

