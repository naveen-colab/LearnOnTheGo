import SwiftUI

struct PodcastsScreen: View {
    @State private var searchText: String = ""
    @State private var playCount: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky red header
                ZStack(alignment: .bottom) {
                    Color(red: 0.92, green: 0.27, blue: 0.27)
                        .frame(height: 90)
                    
                    Text("Podcasts")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
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
                        SectionRowHeader(title: "Keep listening", actionTitle: "")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(MockPodcasts.keepListening) { item in
                                    NavigationLink(destination: PlayLearningCardScreen(
                                        model: LearningCardModel(id: UUID(), title: item.title, description: "", imageName: item.image, learnCards: []),
                                        audioFileName: upcomingAudioFileName()
                                    )) {
                                        PodcastCard(item: item, size: .large)
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { playCount += 1 })
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        // Categories
                        CategorySection(title: "Artificial Intelligence & LLMs", items: MockPodcasts.ai, audioFileProvider: { _ in upcomingAudioFileName() })
                        CategorySection(title: "Cybersecurity", items: MockPodcasts.security, audioFileProvider: { _ in upcomingAudioFileName() })
                        CategorySection(title: "Data Engineering & Analytics", items: MockPodcasts.data, audioFileProvider: { _ in upcomingAudioFileName() })
                        CategorySection(title: "Cloud Native Development", items: MockPodcasts.cloud, audioFileProvider: { _ in upcomingAudioFileName() })
                        CategorySection(title: "Mobile App Development", items: MockPodcasts.mobile, audioFileProvider: { _ in upcomingAudioFileName() })
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func upcomingAudioFileName() -> String {
        // Decide the next file without mutating state (odd -> Taming, even -> OpenShift)
        let next = playCount + 1
        return (next % 2 == 1) ? "Taming_OpenShift.mp3" : "OpenShift.mp3"
    }
}

private struct CategorySection: View {
    let title: String
    let items: [PodcastItem]
    let audioFileProvider: (PodcastItem) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3).bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { item in
                        NavigationLink(destination: PlayLearningCardScreen(
                            model: LearningCardModel(id: UUID(), title: item.title, description: "", imageName: item.image, learnCards: []),
                            audioFileName: audioFileProvider(item)
                        )) {
                            PodcastCard(item: item, size: .medium)
                        }
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
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack {
            Image(item.image)
                .resizable()
                .cornerRadius(8)
                .frame(width: 170, height: 130)
                .scaledToFill()
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
            VStack(alignment: .center, spacing: 8) {
                // Artwork placeholder
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
//            .frame(width: 170, height: 216)
            .padding(12)
        }
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
    let image: String
}

private enum MockPodcasts {
    static let keepListening: [PodcastItem] = [
        .init(artworkTitle: "AI Today", title: "AI Today Podcast", duration: "15 min left", image: "keepListening1"),
        .init(artworkTitle: "Cyber security", title: "Cyber security", duration: "15 min left", image: "keepListening2")
    ]

    static let ai: [PodcastItem] = [
        .init(artworkTitle: "The Rise", title: "The Rise of Generative AI", duration: "12 min", image: "LLM1"),
        .init(artworkTitle: "LLMs", title: "LLMs in Real World Apps", duration: "18 min", image: "LLM1"),
        .init(artworkTitle: "Ethics", title: "Ethical AI Decision Making", duration: "15 min", image: "LLM3")
    ]

    static let security: [PodcastItem] = [
        .init(artworkTitle: "Zero Trust", title: "Zero Trust Explained", duration: "10 min", image: "Cybersecurity1"),
        .init(artworkTitle: "Hacks 2025", title: "Biggest Hacks of 2025", duration: "20 min", image: "Cybersecurity2"),
        .init(artworkTitle: "Infra", title: "Secure Infra Basics", duration: "18 min", image: "Cybersecurity3")
    ]

    static let data: [PodcastItem] = [
        .init(artworkTitle: "ETL", title: "ETL vs ELT in Modern Data Stacks", duration: "16 min", image: "Data1"),
        .init(artworkTitle: "Pipelines", title: "Real-time Data Pipelines", duration: "12 min", image: "Data2"),
        .init(artworkTitle: "Big Data", title: "Big Data Trends", duration: "18 min", image: "Data3")
    ]

    static let cloud: [PodcastItem] = [
        .init(artworkTitle: "K8s", title: "Kubernetes Demystified", duration: "17 min", image: "cloud1"),
        .init(artworkTitle: "Serverless", title: "Serverless Architectures", duration: "18 min", image: "cloud2"),
        .init(artworkTitle: "Cost", title: "Cloud Cost Optimization", duration: "18 min", image: "cloud3")
    ]

    static let mobile: [PodcastItem] = [
        .init(artworkTitle: "Trends", title: "Trends in iOS Development", duration: "14 min", image: "mobile1"),
        .init(artworkTitle: "React Native", title: "Flutter vs React Native", duration: "18 min", image: "mobile1"),
        .init(artworkTitle: "Essentials", title: "Mobile Dev Essentials", duration: "20 min", image: "mobile1")
    ]
}

#Preview {
    PodcastsScreen()
}
