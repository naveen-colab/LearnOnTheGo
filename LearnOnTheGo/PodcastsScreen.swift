import SwiftUI

struct PodcastsScreen: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky red header
                ZStack(alignment: .bottomLeading) {
                    Color(red: 0.92, green: 0.27, blue: 0.27)
                        .frame(height: 96)
                    Text("Podcasts")
                        .font(.title2).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)

                ScrollView {
                    VStack(spacing: 20) {
                        // Search bar
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                            TextField("Search", text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 0.5))

                        // Keep Listening
                        SectionRowHeader(title: "Keep listening", actionTitle: "See All")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(MockPodcasts.keepListening) { item in
                                    PodcastCard(item: item, size: .large)
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Categories
                        CategorySection(title: "Artificial Intelligence & LLMs", items: MockPodcasts.ai)
                        CategorySection(title: "Cybersecurity", items: MockPodcasts.security)
                        CategorySection(title: "Data Engineering & Analytics", items: MockPodcasts.data)
                        CategorySection(title: "Cloud Native Development", items: MockPodcasts.cloud)
                        CategorySection(title: "Mobile App Development", items: MockPodcasts.mobile)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct CategorySection: View {
    let title: String
    let items: [PodcastItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3).bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { item in
                        PodcastCard(item: item, size: .medium)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

private struct SectionRowHeader: View {
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

private struct PodcastCard: View {
    enum Size { case large, medium }
    let item: PodcastItem
    let size: Size

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Artwork placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [Color(.systemGray5), Color(.systemGray3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 240, height: 160)
                .overlay(
                    ZStack(alignment: .bottomLeading) {
                        // Title overlay for mock artwork look
                        VStack(alignment: .leading, spacing: 4) {
                            Spacer()
                            Text(item.artworkTitle)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                                .padding([.horizontal, .bottom], 10)
                        }
                    }
                )

            // Metadata
            Text(item.title)
                .font(.subheadline).bold()
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            HStack {
                Text(item.duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Circle()
                    .fill(Color(red: 1.0, green: 0.92, blue: 0.92))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "play.fill").foregroundStyle(Color(red: 0.92, green: 0.27, blue: 0.27)))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 4)
    }
}

// MARK: - Mock Data

private struct PodcastItem: Identifiable {
    let id = UUID()
    let artworkTitle: String
    let title: String
    let duration: String
}

private enum MockPodcasts {
    static let keepListening: [PodcastItem] = [
        .init(artworkTitle: "AI Today", title: "AI Today Podcast", duration: "15 min left"),
        .init(artworkTitle: "Cyber security", title: "Cyber security", duration: "15 min left")
    ]

    static let ai: [PodcastItem] = [
        .init(artworkTitle: "The Rise", title: "The Rise of Generative AI", duration: "12 min"),
        .init(artworkTitle: "LLMs", title: "LLMs in Real World Apps", duration: "18 min"),
        .init(artworkTitle: "Ethics", title: "Ethical AI Decision Making", duration: "15 min")
    ]

    static let security: [PodcastItem] = [
        .init(artworkTitle: "Zero Trust", title: "Zero Trust Explained", duration: "10 min"),
        .init(artworkTitle: "Hacks 2025", title: "Biggest Hacks of 2025", duration: "20 min"),
        .init(artworkTitle: "Infra", title: "Secure Infra Basics", duration: "18 min")
    ]

    static let data: [PodcastItem] = [
        .init(artworkTitle: "ETL", title: "ETL vs ELT in Modern Data Stacks", duration: "16 min"),
        .init(artworkTitle: "Pipelines", title: "Real-time Data Pipelines", duration: "12 min"),
        .init(artworkTitle: "Big Data", title: "Big Data Trends", duration: "18 min")
    ]

    static let cloud: [PodcastItem] = [
        .init(artworkTitle: "K8s", title: "Kubernetes Demystified", duration: "17 min"),
        .init(artworkTitle: "Serverless", title: "Serverless Architectures", duration: "18 min"),
        .init(artworkTitle: "Cost", title: "Cloud Cost Optimization", duration: "18 min")
    ]

    static let mobile: [PodcastItem] = [
        .init(artworkTitle: "Trends", title: "Trends in iOS Development", duration: "14 min"),
        .init(artworkTitle: "React Native", title: "Flutter vs React Native", duration: "18 min"),
        .init(artworkTitle: "Essentials", title: "Mobile Dev Essentials", duration: "20 min")
    ]
}

#Preview {
    PodcastsScreen()
}

