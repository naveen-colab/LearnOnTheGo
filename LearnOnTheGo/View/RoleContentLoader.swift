import Foundation

// Mirror the existing LearningCardModel shape used in the UI. We assume it already exists in the project.
// To decode from JSON, we define a minimal Decodable projection that can convert into LearningCardModel.
struct LearningCardDTO: Decodable {
    let title: String
    let description: String
    let imageName: String
    let learnCards: [String]
}

struct TopicDTO: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let image: String
}

struct RoleContentDTO: Decodable {
    let role: String
    let headerSubtitle: String
    let recommended: [LearningCardDTO]
    let topics: [TopicDTO]
}

struct RolesPayload: Decodable {
    let roles: [RoleContentDTO]
}

enum RoleContentLoaderError: Error {
    case fileNotFound
    case decodingFailed(Error)
}

final class RoleContentLoader {
    static let shared = RoleContentLoader()

    private init() {}

    func loadRoles() throws -> RolesPayload {
        guard let url = Bundle.main.url(forResource: "roles", withExtension: "json") else {
            throw RoleContentLoaderError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(RolesPayload.self, from: data)
        } catch {
            throw RoleContentLoaderError.decodingFailed(error)
        }
    }
}
