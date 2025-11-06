//
//  LearningCardView.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import SwiftUI

struct LearningCard: View {
    @State var model: LearningCardModel

    // You can adapt this to your real image asset name. For now, try to map from the symbol or use a placeholder.
//    private var imageName: String {
//        // If you have real assets, map them here. We'll use system image fallback.
//        return "image1"
//    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background card and content
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [Color(.systemGray5), Color(.systemGray3)], startPoint: .top, endPoint: .bottom))
                .frame(height: 180)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)

            ZStack(alignment: .bottomLeading) {
                Image(model.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    Text(model.title + model.description)
                        .font(.headline)
                        .lineLimit(2)
                        .truncationMode(.tail)
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
                    PlayLearningCardScreen(model: model)
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

struct TopicCard: View {
    let title: String
    let symbol: String
    let image: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color(.systemGray6), Color(.systemGray4)], startPoint: .top, endPoint: .bottom))
                .frame(height: 150)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 6)

            ZStack(alignment: .bottomLeading) {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline).bold()
                        .foregroundStyle(.white)
                        .padding(12)
                }
            }
        }
    }
}

#Preview {
    LearningCard(model: LearningCardModel(id: UUID(), title: "", description: "", imageName: "", learnCards: [LearnCard]()))
}

